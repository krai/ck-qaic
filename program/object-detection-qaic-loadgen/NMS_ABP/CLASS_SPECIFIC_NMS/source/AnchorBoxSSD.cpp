//==============================================================================
//
// Copyright (c) 2021 Qualcomm Innovation Center, Inc.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted (subject to the limitations in the
// disclaimer below) provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above
//      copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided
//      with the distribution.
//
//    * Neither the name Qualcomm Innovation Center nor the names of its
//      contributors may be used to endorse or promote products derived
//      from this software without specific prior written permission.
//
// NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
// GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
// HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//==============================================================================


#include "../include/AnchorBoxSSD.hpp"
#include "../include/Algorithm.hpp"
#include "../include/Profiler.hpp"
#include "../include/fp16.h"
#include <assert.h>
#include <chrono>
#include <numeric>
#include <math.h>
#include <algorithm>
#include <iostream>
#include <fstream>


AnchorBoxProc::AnchorBoxProc(AnchorBoxConfig& config)
{
    class_threshold = config.classT;
    nms_threshold = config.nmsT;
    class_threshold_in_fp16 = fp16_ieee_from_fp32_value(class_threshold);
    max_detections_per_image = config.maxDetectionsPerImage;
    max_boxes_per_class = config.maxBoxesPerClass;
    /* Since outputs from networks for boxes are in shape
       [1 x NUM_COORDINATES x TOTAL_NUM_BOXES ]
       We iterate this way to avoid doing transpose of data and since
       it is a constant, we declare it here in constructor */
    float *dataPrior = new float [DATA_LENGTH_LOC];
    tPrior = anchor::fTensor({"tPriors", {1, TOTAL_NUM_BOXES, NUM_COORDINATES}, dataPrior});
    read<float, anchor::fTensor>(tPrior,config.priorfilename);
    locScale = config.locScale;
    locOffset = config.locOffset;
    confScale = config.confScale;
    confOffset = config.confOffset;
}


static std::vector<float> decodeLocationTensor(std::vector<float>& loc, const float* prior, const float* variance)
{
    float x = prior[BOX_ITR_0] + loc[0] * variance[0] * prior[BOX_ITR_2];
    float y = prior[BOX_ITR_1] + loc[1] * variance[0] * prior[BOX_ITR_3];
    float width = prior[BOX_ITR_2] * expf(loc[2] * variance[1]);
    float height = prior[BOX_ITR_3] * expf(loc[3] * variance[1]);
    x -= (width / 2.0);
    y -= (height / 2.0);
    width += x;
    height += y;

    return {x, y, width, height};
}


void AnchorBoxProc::anchorBoxProcessingFloatPerBatch(anchor::fTensor &odmLoc, anchor::fTensor &odmConf, std::vector<std::vector<float>>& selectedAll, float& batchIdx)
{
    PROFILE("SSD");
    const anchor::fTensor& odmPrior = tPrior;

    #if 0
    // Enable if wants to performing softmax on CPU
    float * scoresPtr = odmConf.data;
    float * locPtr = odmLoc.data;
    float * priorData = odmPrior.data;
    for(uint32_t i = 0; i < TOTAL_NUM_BOXES; i++,
        scoresPtr += 1,
        locPtr += 1,
        priorData += 1){
        // Algorithm::SoftmaxOpt(scoresPtr, locPtr, NUM_CLASSES, 1.0, 0.0,
        //                         class_threshold, priorData);
        Algorithm::Softmax(scoresPtr, NUM_CLASSES, 1.0, 0.0);
    }
    #endif

    // Already Softmaxed
    uint32_t sizeCount = 0;
    uint32_t count = 0;

    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
        /* Since outputs from networks for confidence scores
            are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
            We iterate this way to avoid doing transpose of data */
        uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
        std::vector<std::vector<float>> result;
        std::vector<std::vector<float>> selected;
        float* odmConfPtr = odmConf.data;
        float* odmLocPtr = odmLoc.data;
        float* odmPriorPtr = odmPrior.data;

        for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
            odmConfPtr += 1,
            odmLocPtr += 1,
            odmPriorPtr += 1) {
            float confidence = odmConfPtr[confItr];
            if (confidence <= class_threshold)
                continue;
            std::vector<float> box = { odmLocPtr[BOX_ITR_0],
                                        odmLocPtr[BOX_ITR_1],
                                        odmLocPtr[BOX_ITR_2],
                                        odmLocPtr[BOX_ITR_3] };
            box = decodeLocationTensor(box, odmPriorPtr, variance.data());
            float labelId = nClsIdx;
            result.emplace_back(
                std::initializer_list<float>{batchIdx, box[1], box[0], box[3], box[2],
                                                confidence,
                                                labelId});
        }

        if(result.size()){
            // To avoid creating call stack if result.size() is 0
            Algorithm::NMS(result, nms_threshold, max_boxes_per_class, selected, selectedAll,class_map);
        }
    }
    // Keep it commented for internal testing
    using box = std::vector<float>;

    int middle = selectedAll.size();
    if(selectedAll.size() > max_detections_per_image){
        middle = max_detections_per_image;
    }
    std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [] (const box& a, const box& b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
                });
}

void AnchorBoxProc::anchorBoxProcessingInt8PerBatch(anchor::iTensor &odmLoc, anchor::iTensor &odmConf, std::vector<std::vector<float>>& selectedAll, float& batchIdx)
{
    PROFILE("SSD");
    const anchor::fTensor& odmPrior = tPrior;

    // Already Softmaxed
    uint32_t sizeCount = 0;
    uint32_t count = 0;

    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
        /* Since outputs from networks for confidence scores
            are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
            We iterate this way to avoid doing transpose of data */
        uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
        std::vector<std::vector<float>> result;
        std::vector<std::vector<float>> selected;
        int8_t* odmConfPtr = odmConf.data;
        int8_t* odmLocPtr = odmLoc.data;
        float* odmPriorPtr = odmPrior.data;

        for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
            odmConfPtr += 1,
            odmLocPtr += 1,
            odmPriorPtr += 1) {
            // Since outputs from networks are in shape 1 x NUM_CLASSES x TOTAL_NUM_BOXES
            // We iterate this way to avoid doing transpose of data
            float confidence = (odmConfPtr[confItr] - confOffset) * confScale ;
            if (confidence <= class_threshold)
                continue;

            // Transform int8_t -> fp32
            std::vector<float> box = { (odmLocPtr[BOX_ITR_0] - locOffset) * locScale,
                                        (odmLocPtr[BOX_ITR_1] - locOffset) * locScale,
                                        (odmLocPtr[BOX_ITR_2] - locOffset) * locScale,
                                        (odmLocPtr[BOX_ITR_3] - locOffset) * locScale};
            box = decodeLocationTensor(box, odmPriorPtr, variance.data());
            float labelId = nClsIdx;
            result.emplace_back(
                std::initializer_list<float>{batchIdx, box[1], box[0], box[3], box[2],
                                                confidence,
                                                labelId});
        }

        if(result.size()){
            // To avoid creating call stack if result.size() is 0
            Algorithm::NMS(result, nms_threshold, max_boxes_per_class, selected, selectedAll, class_map);
        }
    }
    using box = std::vector<float>;

    int middle = selectedAll.size();
    if(selectedAll.size() > max_detections_per_image){
        middle = max_detections_per_image;
    }
    std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [] (const box& a, const box& b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
                });
}

void AnchorBoxProc::anchorBoxProcessingUint8PerBatch(anchor::uTensor &odmLoc, anchor::uTensor &odmConf, std::vector<std::vector<float>>& selectedAll, float& batchIdx)
{
    PROFILE("SSD");
    const anchor::fTensor& odmPrior = tPrior;

    // Already Softmaxed
    uint32_t sizeCount = 0;
    uint32_t count = 0;

    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
        /* Since outputs from networks for confidence scores
            are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
            We iterate this way to avoid doing transpose of data */
        uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
        std::vector<std::vector<float>> result;
        std::vector<std::vector<float>> selected;
        uint8_t* odmConfPtr = odmConf.data;
        uint8_t* odmLocPtr = odmLoc.data;
        float* odmPriorPtr = odmPrior.data;

        for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
            odmConfPtr += 1,
            odmLocPtr += 1,
            odmPriorPtr += 1) {
            // Since outputs from networks are in shape 1 x NUM_CLASSES x TOTAL_NUM_BOXES
            // We iterate this way to avoid doing transpose of data
            float confidence = (CONVERT_TO_INT8(odmConfPtr[confItr]) - confOffset) * confScale ;
            if (confidence <= class_threshold)
                continue;

            // Transform uint8_t -> int8_t -> fp32
            std::vector<float> box = { (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_0]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_1]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_2]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_3]) - locOffset) * locScale};
            box = decodeLocationTensor(box, odmPriorPtr, variance.data());
            float labelId = nClsIdx;
            result.emplace_back(
                std::initializer_list<float>{batchIdx, box[1], box[0], box[3], box[2],
                                                confidence,
                                                labelId});
        }

        if(result.size()){
            // To avoid creating call stack if result.size() is 0
            Algorithm::NMS(result, nms_threshold, max_boxes_per_class, selected, selectedAll,class_map);
        }
    }
    // Keep it commented for internal testing
    using box = std::vector<float>;

    int middle = selectedAll.size();
    if(selectedAll.size() > max_detections_per_image){
        middle = max_detections_per_image;
    }
    std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [] (const box& a, const box& b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
                });
}

// First output in network desc is Location tensor
void AnchorBoxProc::anchorBoxProcessingUint8FloatPerBatch(anchor::uTensor &odmLoc, anchor::fTensor &odmConf, std::vector<std::vector<float>>& selectedAll, float& batchIdx)
{
    PROFILE("SSD");
    const anchor::fTensor& odmPrior = tPrior;

    // Already Softmaxed
    uint32_t sizeCount = 0;
    uint32_t count = 0;

    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
        /* Since outputs from networks for confidence scores
            are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
            We iterate this way to avoid doing transpose of data */
        uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
        std::vector<std::vector<float>> result;
        std::vector<std::vector<float>> selected;
        float* odmConfPtr = odmConf.data;
        uint8_t* odmLocPtr = odmLoc.data;
        float* odmPriorPtr = odmPrior.data;

        for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
            odmConfPtr += 1,
            odmLocPtr += 1,
            odmPriorPtr += 1) {
            float confidence = odmConfPtr[confItr] ;
            if (confidence <= class_threshold)
                continue;

            // Transform uint8_t -> int8_t -> fp32
            std::vector<float> box = { (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_0]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_1]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_2]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_3]) - locOffset) * locScale};
            box = decodeLocationTensor(box, odmPriorPtr, variance.data());
            float labelId = nClsIdx;
            result.emplace_back(
                std::initializer_list<float>{batchIdx, box[1], box[0], box[3], box[2],
                                                confidence,
                                                labelId});
        }

        if(result.size()){
            // To avoid creating call stack if result.size() is 0
            Algorithm::NMS(result, nms_threshold, max_boxes_per_class, selected, selectedAll,class_map);
        }
    }
    // Keep it commented for internal testing
    using box = std::vector<float>;

    int middle = selectedAll.size();
    if(selectedAll.size() > max_detections_per_image){
        middle = max_detections_per_image;
    }
    std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [] (const box& a, const box& b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
                });
}

// First output in network desc is Location tensor
void AnchorBoxProc::anchorBoxProcessingUint8Float16PerBatch(anchor::uTensor &odmLoc, anchor::hfTensor &odmConf, std::vector<std::vector<float>>& selectedAll, float& batchIdx)
{
    PROFILE("SSD");
    const anchor::fTensor& odmPrior = tPrior;

    // Already Softmaxed
    uint32_t sizeCount = 0;
    uint32_t count = 0;

    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
        /* Since outputs from networks for confidence scores
            are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
            We iterate this way to avoid doing transpose of data */
        uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
        std::vector<std::vector<float>> result;
        std::vector<uint16_t> scores;
        std::vector<std::vector<float>> selected;
        uint16_t* odmConfPtr = odmConf.data;
        uint8_t* odmLocPtr = odmLoc.data;
        float* odmPriorPtr = odmPrior.data;

        for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
            odmConfPtr += 1,
            odmLocPtr += 1,
            odmPriorPtr += 1) {
            // fp16 is treated internally as uint16, and since this is softmax output, all values are in 0-1, and mantissa is 0
            // hence is it ok to compare without conversion to fp32
            uint16_t confidence = odmConfPtr[confItr] ;
            if (confidence <= class_threshold_in_fp16)
                continue;

            // Transform uint8_t -> int8_t -> fp32
            std::vector<float> box = { (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_0]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_1]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_2]) - locOffset) * locScale,
                                        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_3]) - locOffset) * locScale};
            box = decodeLocationTensor(box, odmPriorPtr, variance.data());
            float labelId = nClsIdx;
            result.emplace_back(
                std::initializer_list<float>{batchIdx, box[1], box[0], box[3], box[2],
                                                0,
                                                labelId});
            scores.push_back(confidence);
        }

        if(result.size()){
            // To avoid creating call stack if result.size() is 0
            Algorithm::NMS_FP16(result, scores, nms_threshold, max_boxes_per_class, selected, selectedAll,class_map);
        }
    }
    // Keep it commented for internal testing
    using box = std::vector<float>;

    int middle = selectedAll.size();
    if(selectedAll.size() > max_detections_per_image){
        middle = max_detections_per_image;
    }
    std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [] (const box& a, const box& b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
                });
}
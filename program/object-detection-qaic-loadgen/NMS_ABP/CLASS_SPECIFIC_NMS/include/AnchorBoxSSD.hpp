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


#ifndef MLPERF_R34_MV1_SSD_SSD_HPP
#define MLPERF_R34_MV1_SSD_SSD_HPP

#include <iostream>
#include "fp16.h"
#include <vector>
#include <math.h>
#include <fstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <algorithm>

#if MODEL_R34
    #define NUM_CLASSES 81
    #define MAX_BOXES_PER_CLASS 100
    #define TOTAL_NUM_BOXES 15130

    #define DATA_LENGTH_LOC 60520
    #define DATA_LENGTH_CONF 1225530
    #define MAP_CLASSES 1

    #define BOX_ITR_0 0
    #define BOX_ITR_1 15130
    #define BOX_ITR_2 30260
    #define BOX_ITR_3 45390

    #define OFFSET_CONF 15130
    #define STEP_CONF_PTR 1
    #define STEP_LOC_PTR 1
    #define STEP_PRIOR_PTR 1
    #define BOXES_INDEX 0
    #define CLASSES_INDEX 1
#else
    #define NUM_CLASSES 91
    #define MAX_BOXES_PER_CLASS 100
    #define TOTAL_NUM_BOXES 1917


    #define DATA_LENGTH_LOC 7668
    #define DATA_LENGTH_CONF 174447

    #define BOX_ITR_0 0
    #define BOX_ITR_1 1
    #define BOX_ITR_2 2
    #define BOX_ITR_3 3

    #define MAP_CLASSES 0

    #define OFFSET_CONF 1
    #define STEP_CONF_PTR 91
    #define STEP_LOC_PTR 4
    #define STEP_PRIOR_PTR 4
    #define BOXES_INDEX 1
    #define CLASSES_INDEX 0
#endif

#define _UINT8_TO_INT8 128
#define CONVERT_TO_INT8(x) (int8_t)((int16_t)x - _UINT8_TO_INT8)
#define CLASS_POSITION 6
#define SCORE_POSITION 5
#define NUM_COORDINATES 4
#define BATCH_SIZE 4

namespace anchor
{
    struct uTensor
    {
        std::string name;
        std::vector<uint64_t> dim;
        uint8_t* data;
    };
    struct fTensor
    {
        std::string name;
        std::vector<uint64_t> dim;
        float* data;
    };

    struct hfTensor{
        std::string name;
        std::vector<uint64_t> dim;
        uint16_t* data;
    };
};

struct AnchorBoxConfig{
    float classT;
    float nmsT;
    std::string priorfilename;
    uint32_t maxDetectionsPerImage;
    uint32_t maxBoxesPerClass;

    float locOffset;
    float locScale;

    float confOffset;
    float confScale;
};


// Api to read data from raw/bin file into tensor
template<typename T, typename Tensor>
static void read(Tensor tensor, std::string filename) {
    std::ifstream fs(filename, std::ifstream::binary);
    fs.seekg(0, std::ios::end);
    uint32_t length = fs.tellg();
    fs.seekg(0, std::ios::beg);
    uint32_t tensorLength = uint32_t(sizeof(T));
    // std::cout << tensorLength << std::endl;
    for(auto dim : tensor.dim){
        tensorLength *= dim;
    }
    #if DEBUG_TRACES
    std::cout << tensorLength << " Bytes to be read from " << filename << std::endl;
    #endif
    if (tensorLength != length) {
        std::cerr << "Invalid input: " << filename << std::endl;
        std::cerr << "Length mismatch for " << tensor.name << " tensorSize: " << tensorLength << " fileSize: " << length  << std::endl;
        std::exit(1);
    }
    fs.read((char *)tensor.data, tensorLength);
    fs.close();
}

class AnchorBoxProc
{
public:
    AnchorBoxProc(AnchorBoxConfig & config);
    void anchorBoxProcessingFloatPerBatch(anchor::fTensor &odcLoc, anchor::fTensor &odmConf, std::vector<std::vector<float>>& result, float& batchidx);
    void anchorBoxProcessingUint8PerBatch(anchor::uTensor &odcLoc, anchor::uTensor &odmConf, std::vector<std::vector<float>>& result, float& batchidx);
    void anchorBoxProcessingUint8Float16PerBatch(anchor::uTensor &odcLoc, anchor::hfTensor &odmConf, std::vector<std::vector<float>>& result, float& batchidx);
    anchor::fTensor tPrior;
    float class_threshold, nms_threshold;
    uint32_t max_detections_per_image;
    uint32_t max_boxes_per_class;
    // float * odmConfFloat, odmLocFloat;
    float locScale, locOffset;
    float confScale, confOffset;
    std::vector<float> variance = {0.1, 0.2};
    uint16_t class_threshold_in_fp16;
    std::vector<float> class_map = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 67, 70, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 84, 85, 86, 87, 88, 89, 90};
    ~AnchorBoxProc(){
        delete tPrior.data;
    };
};

#endif //MLPERF_R34_MV1_SSD_SSD_HPP

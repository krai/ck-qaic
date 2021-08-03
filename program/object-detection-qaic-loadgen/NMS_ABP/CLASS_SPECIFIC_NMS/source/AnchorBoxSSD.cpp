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
#include "../include/NMS.hpp"
#include "../include/Profiler.hpp"
#include "../include/fp16.h"
#include <assert.h>
#include <chrono>
#include <numeric>
#include <math.h>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <cmath>

AnchorBoxProc::AnchorBoxProc(AnchorBoxConfig &config) {
  class_threshold = config.classT;
  nms_threshold = config.nmsT;
  class_threshold_in_fp16 = fp16_ieee_from_fp32_value(class_threshold);
  max_detections_per_image = config.maxDetectionsPerImage;
  max_boxes_per_class = config.maxBoxesPerClass;
  /* Since outputs from networks for boxes are in shape
     [1 x NUM_COORDINATES x TOTAL_NUM_BOXES ]
     We iterate this way to avoid doing transpose of data and since
     it is a constant, we declare it here in constructor */
  float *dataPrior = new float[DATA_LENGTH_LOC];
  tPrior = anchor::fTensor(
      { "tPriors", { 1, TOTAL_NUM_BOXES, NUM_COORDINATES }, dataPrior });
  read<float, anchor::fTensor>(tPrior, config.priorfilename);
  locScale = config.locScale;
  locOffset = config.locOffset;
  confScale = config.confScale;
  confOffset = config.confOffset;
}
static std::vector<float> decodeLocationTensor(std::vector<float> &loc,
                                               const float *prior,
                                               const float *variance) {
  float x = prior[BOX_ITR_0] + loc[0] * variance[0] * prior[BOX_ITR_2];
  float y = prior[BOX_ITR_1] + loc[1] * variance[0] * prior[BOX_ITR_3];
  float width = prior[BOX_ITR_2] * expf(loc[2] * variance[1]);
  float height = prior[BOX_ITR_3] * expf(loc[3] * variance[1]);
  x -= (width / 2.0f);
  y -= (height / 2.0f);
  width += x;
  height += y;

  return { x, y, width, height };
}
static std::vector<float> mv1SSD_decodeLocationTensor(std::vector<float> &loc,
                                                      const float *prior) {
  float wx = 10;
  float wy = 10;
  float ww = 5;
  float wh = 5;

  float boxes_x1 = prior[1];
  float boxes_y1 = prior[0];
  float boxes_x2 = prior[3];
  float boxes_y2 = prior[2];

  float dx = loc[1];
  float dy = loc[0];
  float dw = loc[3];
  float dh = loc[2];

  float widths = boxes_x2 - boxes_x1;
  float heights = boxes_y2 - boxes_y1;
  float ctr_x = boxes_x1 + 0.5f * widths;
  float ctr_y = boxes_y1 + 0.5f * heights;

  dx = dx / wx;
  dy = dy / wy;
  dw = dw / ww;
  dh = dh / wh;

  float pred_ctr_x = dx * widths + ctr_x;
  float pred_ctr_y = dy * heights + ctr_y;
  float pred_w = exp(dw) * widths;
  float pred_h = exp(dh) * heights;

  return { pred_ctr_x - 0.5f * pred_w, pred_ctr_y - 0.5f * pred_h,
           pred_ctr_x + 0.5f * pred_w, pred_ctr_y + 0.5f * pred_h };
}

void AnchorBoxProc::anchorBoxProcessingFloatPerBatch(
    anchor::fTensor &odmLoc, anchor::fTensor &odmConf,
    std::vector<std::vector<float> > &selectedAll, float &batchIdx) {
//  PROFILE("SSD");
  const anchor::fTensor &odmPrior = tPrior;

  float *baseConfPtr = odmConf.data;
  float *baseLocPtr = odmLoc.data;
  float *odmConfPtr = odmConf.data;
  float *odmLocPtr = odmLoc.data;

  std::vector<std::vector<float> > selectedPerBatch;
  for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
    uint32_t confItr = nClsIdx * OFFSET_CONF;
    // OFFSET_CONF = TOTAL_NUM_BOXES -> R34SSD because output-dimension is [1,
    // 81, 15130]
    // OFFSET_CONF = 1 -> MV1SSD because output-dimension is [1, 1917, 91]
    std::vector<std::vector<float> > result;
    std::vector<std::vector<float> > selected;
    odmConfPtr = baseConfPtr;
    odmLocPtr = baseLocPtr;
    float *odmPriorPtr = odmPrior.data;
    for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
                  odmConfPtr += STEP_CONF_PTR, odmLocPtr += STEP_LOC_PTR,
                  odmPriorPtr += STEP_PRIOR_PTR) {
      float confidence = odmConfPtr[confItr];
      if (confidence <= class_threshold)
        continue;
      std::vector<float> box = { odmLocPtr[BOX_ITR_0], odmLocPtr[BOX_ITR_1],
                                 odmLocPtr[BOX_ITR_2], odmLocPtr[BOX_ITR_3] };
#if MODEL_R34
      box = decodeLocationTensor(box, odmPriorPtr, variance.data());
#else
      box = mv1SSD_decodeLocationTensor(box, odmPriorPtr);
#endif // For MV1 decoding logic is inside the model.
      float labelId = nClsIdx;
      result.emplace_back(
          std::initializer_list<float>{ batchIdx, box[1],     box[0], box[3],
                                        box[2],   confidence, labelId });
    }

    if (result.size()) {
      // To avoid creating call stack if result.size() is 0
      NMS_fp32(result, nms_threshold, max_boxes_per_class, selected,
               selectedAll, class_map);
    }
  }
  // Keep it commented for internal testing
  using box = std::vector<float>;

  int middle = selectedAll.size();
  if (middle > max_detections_per_image) {
    middle = max_detections_per_image;
  }
  std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle,
                    selectedAll.end(), [](const box &a, const box &b) {
    return a[SCORE_POSITION] > b[SCORE_POSITION];
  });
}

void AnchorBoxProc::anchorBoxProcessingUint8PerBatch(
    anchor::uTensor &odmLoc, anchor::uTensor &odmConf,
    std::vector<std::vector<float> > &selectedAll, float &batchIdx) {
  //PROFILE("SSD");
  const anchor::fTensor &odmPrior = tPrior;

  uint8_t *odmConfPtr = odmConf.data;
  uint8_t *odmLocPtr = odmLoc.data;
  float *odmPriorPtr = odmPrior.data;
  std::vector<std::vector<float> > result[NUM_CLASSES];
  std::vector<std::vector<float> > selected[NUM_CLASSES];

  for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES;
       ++nBoxIdx, odmLocPtr += 4, odmPriorPtr += 4) {
    uint32_t confItr = nBoxIdx * NUM_CLASSES;
    for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
      uint8_t confi = odmConfPtr[confItr+nClsIdx];
      if (confi < 76)
        continue;
      float confidence = confi  * confScale;

      // Transform uint8_t -> int8_t -> fp32
      std::vector<float> box = {
        (CONVERT_TO_INT8(odmLocPtr[0]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[1]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[2]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[3]) - locOffset) * locScale
      };
      
      box = mv1SSD_decodeLocationTensor(box, odmPriorPtr);
      
      float labelId = nClsIdx;
      result[nClsIdx].emplace_back(
          std::initializer_list<float>{ batchIdx, box[1], box[0], box[3],
                                        box[2], confidence, labelId });
    }
  }
  for (uint32_t j = 1; j < NUM_CLASSES; j++) {

    if (result[j].size()) {
      // To avoid creating call stack if result.size() is 0
      NMS_fp32(result[j], nms_threshold, max_boxes_per_class, selected[j],
               selectedAll, class_map);
    }
  }
  // Keep it commented for internal testing
  using box = std::vector<float>;

  int middle = selectedAll.size();
  if (middle > max_detections_per_image) {
    middle = max_detections_per_image;
  }
  std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle,
                    selectedAll.end(), [](const box &a, const box &b) {
    return a[SCORE_POSITION] > b[SCORE_POSITION];
  });
}

// First output in network desc is Location tensor
void AnchorBoxProc::anchorBoxProcessingUint8Float16PerBatch(
    anchor::uTensor &odmLoc, anchor::hfTensor &odmConf,
    std::vector<std::vector<float> > &selectedAll, float &batchIdx) {
  //PROFILE("SSD");
  const anchor::fTensor &odmPrior = tPrior;

  uint16_t *baseConfPtr = odmConf.data;
  uint8_t *baseLocPtr = odmLoc.data;
  uint16_t *odmConfPtr = odmConf.data;
  uint8_t *odmLocPtr = odmLoc.data;

  std::vector<std::vector<float> > selectedPerBatch;

  for (uint32_t nClsIdx = 1; nClsIdx < NUM_CLASSES; nClsIdx++) {
    /* Since outputs from networks for confidence scores
        are in shape [1 x NUM_CLASSES x TOTAL_NUM_BOXES ]
        We iterate this way to avoid doing transpose of data */
    uint32_t confItr = nClsIdx * TOTAL_NUM_BOXES;
    std::vector<std::vector<float> > result;
    std::vector<uint16_t> scores;
    std::vector<std::vector<float> > selected;
    odmConfPtr = baseConfPtr;
    odmLocPtr = baseLocPtr;
    float *odmPriorPtr = odmPrior.data;

    for (uint32_t nBoxIdx = 0; nBoxIdx < TOTAL_NUM_BOXES; ++nBoxIdx,
                  odmConfPtr += STEP_CONF_PTR, odmLocPtr += STEP_LOC_PTR,
                  odmPriorPtr += STEP_PRIOR_PTR) {
      // fp16 is treated internally as uint16, and since this is softmax output,
      // all values are in 0-1, and mantissa is 0
      // hence is it ok to compare without conversion to fp32
      uint16_t confidence = odmConfPtr[confItr];
      if (confidence <= class_threshold_in_fp16)
        continue;

      // Transform uint8_t -> int8_t -> fp32
      std::vector<float> box = {
        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_0]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_1]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_2]) - locOffset) * locScale,
        (CONVERT_TO_INT8(odmLocPtr[BOX_ITR_3]) - locOffset) * locScale
      };
#if MODEL_R34
      box = decodeLocationTensor(box, odmPriorPtr, variance.data());
#endif // For MV1 decoding logic is inside the model.
      float labelId = nClsIdx;
      result.emplace_back(
          std::initializer_list<float>{ batchIdx, box[1], box[0], box[3],
                                        box[2],   0,      labelId });
      scores.push_back(confidence);
    }

    if (result.size()) {
      // To avoid creating call stack if result.size() is 0
      NMS_fp16(result, scores, nms_threshold, max_boxes_per_class, selected,
               selectedAll, class_map);
    }
  }
  // Keep it commented for internal testing
  using box = std::vector<float>;

  int middle = selectedAll.size();
  if (middle > max_detections_per_image) {
    middle = max_detections_per_image;
  }
  std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle,
                    selectedAll.end(), [](const box &a, const box &b) {
    return a[SCORE_POSITION] > b[SCORE_POSITION];
  });
}

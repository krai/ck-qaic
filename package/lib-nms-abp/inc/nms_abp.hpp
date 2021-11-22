//
// Copyright (c) 2021 Krai Ltd.
//
// SPDX-License-Identifier: BSD-3-Clause.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 


#include <iostream>
#include <math.h>
#include <fstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <algorithm>

#include "fp16.h"
template<typename Loc, typename Conf, typename MParams>
class NMS_ABP
{
   std::string binPath;
   public:
   std::string priorName;
   float* priorTensor;
   MParams modelParams;
   NMS_ABP() {
      binPath  = std::getenv("PRIOR_BIN_PATH");
      if(binPath == "") binPath=".";
      readPriors();
   }
   ~NMS_ABP(){
      delete priorTensor;
   };
   float* read(std::string priorFilename, uint32_t tensorLength) {
      std::ifstream fs(binPath + "/" + priorFilename, std::ifstream::binary);
      fs.seekg(0, std::ios::end);
      uint32_t fileSize = fs.tellg();
      fs.seekg(0, std::ios::beg);

      if (tensorLength != fileSize) {
         std::cerr << "Invalid input: " << priorFilename << std::endl;
         std::cerr << "Length mismatch: " << " Tensor Size: " << tensorLength << ",\t File Size: " << fileSize  << std::endl;
         std::exit(1);
      }
      float* priorData = new float[tensorLength];
      fs.read((char *)priorData, tensorLength);
      fs.close();
      return priorData;
   }
   public:
   void readPriors() {
      priorTensor = read(modelParams.priorName, modelParams.TOTAL_NUM_BOXES * NUM_COORDINATES * sizeof (float));
   }
   void anchorBoxProcessing(const Loc * const locTensor, const Conf * const confTensor, std::vector<bbox> &selectedAll, const float idx) {

      const Conf* confPtr = confTensor;
      const Loc* locPtr = locTensor;
      float const * priorPtr = priorTensor;
      
      if(modelParams.BOXES_INDEX == 0) {
         for (uint32_t ci = 1; ci < modelParams.NUM_CLASSES; ci++) {
            uint32_t confItr = ci * modelParams.OFFSET_CONF;
            std::vector<bbox> result;
            std::vector<Conf> scores;
            std::vector<bbox> selected;
            confPtr = confTensor;
            locPtr = locTensor;
            priorPtr = priorTensor;
            for (uint32_t bi = 0; bi < modelParams.TOTAL_NUM_BOXES; ++bi, confPtr++, locPtr++, priorPtr++) {

               Conf confidence = confPtr[confItr];
               if (!above_Class_Threshold(confidence))
                  continue;
               bbox cBox = { get_Loc_Val(locPtr[modelParams.BOX_ITR_0]), get_Loc_Val(locPtr[modelParams.BOX_ITR_1]), 
                  get_Loc_Val(locPtr[modelParams.BOX_ITR_2]), get_Loc_Val(locPtr[modelParams.BOX_ITR_3]) 
               };
               if(modelParams.variance.data() != NULL)
                  cBox = decodeLocationTensorWithVariance(cBox, priorPtr, modelParams.variance.data());
               else
                  cBox = decodeLocationTensor(cBox, priorPtr);
               result.emplace_back(
                     std::initializer_list<float>{idx, cBox[1], cBox[0], cBox[3], cBox[2], 0, (float)ci });
               scores.push_back(confidence);
            }

            if (result.size()) {
               NMS(result, scores, modelParams.NMS_THRESHOLD, modelParams.MAX_BOXES_PER_CLASS, selected, selectedAll, modelParams.class_map);
            }
         }
      }
      else {
         std::vector<bbox> result[modelParams.NUM_CLASSES];
         std::vector<bbox> selected[modelParams.NUM_CLASSES];
         std::vector<Conf> scores[modelParams.NUM_CLASSES];
         float const * priorPtr = priorTensor;
         for (uint32_t bi = 0; bi < modelParams.TOTAL_NUM_BOXES; bi++, locPtr+=4, priorPtr+=4) {
            uint32_t confItr = bi * modelParams.NUM_CLASSES;
            for (uint32_t ci = 1; ci < modelParams.NUM_CLASSES; ci++) {

               Conf confidence = confPtr[confItr+ci];
               if (!above_Class_Threshold(confidence))
                  continue;
               bbox cBox = { get_Loc_Val(locPtr[modelParams.BOX_ITR_0]), get_Loc_Val(locPtr[modelParams.BOX_ITR_1]), 
                  get_Loc_Val(locPtr[modelParams.BOX_ITR_2]), get_Loc_Val(locPtr[modelParams.BOX_ITR_3]) 
               };
               if(modelParams.variance.data() != NULL)
                  cBox = decodeLocationTensorWithVariance(cBox, priorPtr, modelParams.variance.data());
               else
                  cBox = decodeLocationTensor(cBox, priorPtr);
               result[ci].emplace_back(
                     std::initializer_list<float>{idx, cBox[1], cBox[0], cBox[3], cBox[2], 0, (float)ci });
               scores[ci].push_back(confidence);
            }
         }
         for (uint32_t ci = 1; ci < modelParams.NUM_CLASSES; ci++) {
            if (result[ci].size()) {
               NMS(result[ci], scores[ci], modelParams.NMS_THRESHOLD, modelParams.MAX_BOXES_PER_CLASS, selected[ci], selectedAll, modelParams.class_map);
            }
         }
      }

      int middle = selectedAll.size();
      if (middle > modelParams.MAX_DETECTIONS_PER_IMAGE) {
         middle = modelParams.MAX_DETECTIONS_PER_IMAGE;
      }
      std::partial_sort(selectedAll.begin(), selectedAll.begin() + middle, selectedAll.end(), [](const bbox &a, const bbox &b) {
            return a[SCORE_POSITION] > b[SCORE_POSITION];
            });
   }
   inline Conf above_Class_Threshold(uint8_t score) {
      return score > modelParams.CLASS_THRESHOLD_UINT8; 
   }
   inline Conf above_Class_Threshold(uint16_t score) {
      return score > modelParams.CLASS_THRESHOLD_FP16; 
   }
   inline Conf above_Class_Threshold(float score) {
      return score > modelParams.CLASS_THRESHOLD; 
   }
   inline float get_Loc_Val(uint8_t x) {
      return CONVERT_UINT8_FP32(x, modelParams.LOC_OFFSET, modelParams.LOC_SCALE); 
   }
   inline float get_Loc_Val(float x) {
      return x; 
   }
   inline float get_Score_Val(uint16_t x) {
      return fp16_ieee_to_fp32_value(x);
   }
   inline float get_Score_Val(uint8_t x) {
      return CONVERT_UINT8_FP32(x, modelParams.CONF_OFFSET, modelParams.CONF_SCALE);;
   }
   inline float get_Score_Val(float x) {
      return x;
   }
   bbox decodeLocationTensorWithVariance(const bbox &loc, const float * const prior, const float * const var) {
      float x = prior[modelParams.BOX_ITR_0] + loc[0] * var[0] * prior[modelParams.BOX_ITR_2];
      float y = prior[modelParams.BOX_ITR_1] + loc[1] * var[0] * prior[modelParams.BOX_ITR_3];
      float w = prior[modelParams.BOX_ITR_2] * expf(loc[2] * var[1]);
      float h = prior[modelParams.BOX_ITR_3] * expf(loc[3] * var[1]);
      x -= (w / 2.0f);
      y -= (h / 2.0f);
      w += x;
      h += y;

      return { x, y, w, h };
   }
   bbox decodeLocationTensor(const bbox &loc, const float * const prior) {

      float box_x1 = prior[1];
      float box_y1 = prior[0];
      float box_x2 = prior[3];
      float box_y2 = prior[2];

      float dx = loc[1]/10.0f;
      float dy = loc[0]/10.0f;
      float dw = loc[3]/5.0f;
      float dh = loc[2]/5.0f;

      float w = box_x2 - box_x1;
      float h = box_y2 - box_y1;
      float cent_x = box_x1 + 0.5f * w;
      float cent_y = box_y1 + 0.5f * h;

      float pred_cent_x = dx * w + cent_x;
      float pred_cent_y = dy * h + cent_y;
      float pred_w = expf(dw) * w;
      float pred_h = expf(dh) * h;

      return { pred_cent_x - 0.5f * pred_w, pred_cent_y - 0.5f * pred_h,
         pred_cent_x + 0.5f * pred_w, pred_cent_y + 0.5f * pred_h };
   }

   template <typename A, typename B>
      void pack(const std::vector<A> &part1, const std::vector<B> &part2,
            std::vector<std::pair<A, B> > &packed) {
         assert(part1.size() == part2.size());
         for (size_t i = 0; i < part1.size(); i++) {
            packed.push_back(std::make_pair(part1[i], part2[i]));
         }
      }

   template <typename A, typename B>
      void unpack(const std::vector<std::pair<A, B> > &packed, std::vector<A> &part1,
            std::vector<B> &part2) {
         for (size_t i = 0; i < part1.size(); i++) {
            part1[i] = packed[i].first;
            part2[i] = packed[i].second;
         }
      }
#define AREA(y1, x1, y2, x2) ((y2 - y1) * (x2 - x1))
   float computeIOU(const float *box1, const float *box2) {
      float box1_y1 = box1[1], box1_x1 = box1[2], box1_y2 = box1[3],
      box1_x2 = box1[4];
      float box2_y1 = box2[1], box2_x1 = box2[2], box2_y2 = box2[3],
            box2_x2 = box2[4];

      assert(box1_y1 < box1_y2 && box1_x1 < box1_x2);
      assert(box2_y1 < box2_y2 && box2_x1 < box2_x2);

      float inter_y1 = std::max(box1_y1, box2_y1);
      float inter_x1 = std::max(box1_x1, box2_x1);
      float inter_y2 = std::min(box1_y2, box2_y2);
      float inter_x2 = std::min(box1_x2, box2_x2);

      float IOU = 0.0f;

      if ((inter_y1 < inter_y2) &&
            (inter_x1 < inter_x2)) // there is a valid intersection
      {
         float intersect = AREA(inter_y1, inter_x1, inter_y2, inter_x2);
         float total = AREA(box1_y1, box1_x1, box1_y2, box1_x2) +
            AREA(box2_y1, box2_x1, box2_y2, box2_x2) - intersect;
         IOU = total > 0.0f ? (intersect / total) : 0.0f;
      }
      return IOU;
   }

   void insertSelected(std::vector<std::vector<float> > &selected,
         std::vector<std::vector<float> > &selectedAll,
         std::vector<float> &cand, const float &thres,
         std::vector<Conf> &scores, int index,
         std::vector<float> &classmap) {
      for (int i = 0; i < selected.size(); i++) {
         if (computeIOU(&cand[0], &selected[i][0]) > thres) {
            return;
         }
      }
      cand[SCORE_POSITION] = get_Score_Val(scores[index]);
      if (modelParams.MAP_CLASSES)
         cand[CLASS_POSITION] = classmap[cand[CLASS_POSITION]];
      selected.push_back(cand);
      selectedAll.push_back(cand);
   }

   void NMS(std::vector<std::vector<float> > &boxes,
         std::vector<Conf> &scores, const float &thres,
         const int &max_output_size,
         std::vector<std::vector<float> > &selected,
         std::vector<std::vector<float> > &selectedAll,
         std::vector<float> &classmap) {
      std::vector<std::pair<std::vector<float>, Conf> > packed;
      assert(boxes.size() == scores.size());
      pack(boxes, scores, packed);

      std::sort(
            std::begin(packed), std::end(packed),
            [&](const auto &a, const auto &b) { return (a.second > b.second); });
      unpack(packed, boxes, scores);
      for (int i = 0; (i < boxes.size()) && (selected.size() < max_output_size);
            i++) {
         insertSelected(selected, selectedAll, boxes[i], thres, scores, i,
               classmap);
      }
   } 
};

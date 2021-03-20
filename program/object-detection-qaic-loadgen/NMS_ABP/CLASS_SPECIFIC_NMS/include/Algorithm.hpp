/*
Qualcomm Technologies, Inc.Proprietary
(c) 2020 Qualcomm Technologies, Inc.All rights reserved.

All data and information contained in or disclosed by this document are
confidential and proprietary information of Qualcomm Technologies, Inc., and
all rights therein are expressly reserved.By accepting this material, the
recipient agrees that this materialand the information contained therein
are held in confidenceand in trustand will not be used, copied, reproduced
in whole or in part, nor its contents revealed in any manner to others
without the express written permission of Qualcomm Technologies, Inc.
*/

#ifndef MLPERF_R34SSD_ALGORITHM_HPP
#define MLPERF_R34SSD_ALGORITHM_HPP

#include <cstdint>
#include <vector>

namespace Algorithm
{
void SoftmaxOpt(float* tensor, float * loc, uint32_t size, float scale, float offsets, float thresh, float* prior);

void Softmax(float* tensor, uint32_t size, float scale, float offsets);

void NMS(std::vector<std::vector<float>> &boxes,
            const float& thres, const int& max_output_size,
            std::vector<std::vector<float>> &selected,
            std::vector<std::vector<float>> &selectedAll,
            std::vector<float> & classmap);

void NMS_FP16(std::vector<std::vector<float>> &boxes, std::vector<uint16_t>& scores,
                const float& thres, const int& max_output_size,
                std::vector<std::vector<float>> &selected,
                std::vector<std::vector<float>> &selectedAll,
                std::vector<float>& classmap);
}

#endif //MLPERF_R34SSD_ALGORITHM_HPP

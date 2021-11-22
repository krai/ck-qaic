#include "nms_abp.h"

int main() {
 NMS_ABP<float, float, R34_Params> r34_float_nms_processor;
 NMS_ABP<uint8_t, uint16_t, R34_Params> r34_nms_processor;
 NMS_ABP<float, float, MV1_Params> mv1_float_nms_processor;
 NMS_ABP<uint8_t, uint8_t, R34_Params> mv1_nms_processor;
}

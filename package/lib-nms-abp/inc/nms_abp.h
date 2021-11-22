#include <vector>

class R34_Params {
   public: 
      const int NUM_CLASSES = 81;
      const int MAX_BOXES_PER_CLASS = 100;
      const int TOTAL_NUM_BOXES = 15130;

      const int DATA_LENGTH_LOC = 60520;
      const int DATA_LENGTH_CONF = 1225530;

      const int BOX_ITR_0 = 0;
      const int BOX_ITR_1 = (TOTAL_NUM_BOXES*1);
      const int BOX_ITR_2 = (TOTAL_NUM_BOXES*2);
      const int BOX_ITR_3 = (TOTAL_NUM_BOXES*3);

      const int OFFSET_CONF = 15130;
      const int BOXES_INDEX = 0;
      const int CLASSES_INDEX = 1;

      const float LOC_OFFSET = 0.0f;
      const float LOC_SCALE = 0.136092901f;
      const float CONF_OFFSET = 0.0f;
      const float CONF_SCALE = 1.0f;

      const float CLASS_THRESHOLD = 0.05f;
      const int CLASS_THRESHOLD_UINT8 = 0; //fixme
      const int CLASS_THRESHOLD_FP16 = 10854;
      const float NMS_THRESHOLD = 0.5f;
      const int MAX_DETECTIONS_PER_IMAGE = 600;
      const int MAX_DETECTIONS_PER_CLASS = 100;

      const char* priorName = "R34_priors.bin";
      const bool MAP_CLASSES = true;
      std::vector<float> variance = {0.1, 0.2};
      std::vector<float> class_map = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 67, 70, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 84, 85, 86, 87, 88, 89, 90};
};
class MV1_Params {
   public: 
      const int NUM_CLASSES = 91;
      const int MAX_BOXES_PER_CLASS = 100;
      const int TOTAL_NUM_BOXES = 1917;

      const int DATA_LENGTH_LOC = 7668;
      const int DATA_LENGTH_CONF = 17447;

      const int BOX_ITR_0 = 0;
      const int BOX_ITR_1 = 1;
      const int BOX_ITR_2 = 2;
      const int BOX_ITR_3 = 3;

      const int OFFSET_CONF = 1;
      const int BOXES_INDEX = 1;
      const int CLASSES_INDEX = 0;

      const float LOC_OFFSET = 0.0f;
      const float LOC_SCALE = 0.144255146f;
      const float CONF_OFFSET = -128.0f;
      const float CONF_SCALE = 0.00392156886f;

      const float CLASS_THRESHOLD = 0.3f;
      const int CLASS_THRESHOLD_UINT8 = 76; 
      const int CLASS_THRESHOLD_FP16 = 0;//fixme
      const float NMS_THRESHOLD = 0.45f;
      const int MAX_DETECTIONS_PER_IMAGE = 100;
      const int MAX_DETECTIONS_PER_CLASS = 100;

      const char* priorName = "MV1_priors.bin";
      const bool MAP_CLASSES = false;
      std::vector<float> variance = {};
      std::vector<float> class_map = {};
};


#define MV1_NUM_CLASSES 91
#define MV1_MAX_BOXES_PER_CLASS 100
#define MV1_TOTAL_NUM_BOXES 1917


#define MV1_DATA_LENGTH_LOC 7668
#define MV1_DATA_LENGTH_CONF 174447

#define MV1_BOX_ITR_0 0
#define MV1_BOX_ITR_1 1
#define MV1_BOX_ITR_2 2
#define MV1_BOX_ITR_3 3

#define MV1_MAP_CLASSES 0

#define MV1_OFFSET_CONF 1
#define MV1_STEP_CONF_PTR 91
#define MV1_STEP_LOC_PTR 4
#define MV1_STEP_PRIOR_PTR 4
#define MV1_BOXES_INDEX 1
#define MV1_CLASSES_INDEX 0

#define MV1_LOC_OFFSET 0
#define MV1_LOC_SCALE 0.144255146f
#define MV1_CONF_OFFSET -128
#define MV1_CONF_SCALE 0.00392156886f

#define MV1_CLASS_THRESHOLD 0.3
#define MV1_CLASS_THRESHOLD_UINT8 76
#define MV1_NMS_THRESHOLD 0.45
#define MV1_MAX_DETECTIONS_PER_IMAGE 100
#define MV1_MAX_DETECTIONS_PER_CLASS 100

#define CONVERT_TO_INT8(x) ((int8_t)((int16_t)x - 128))
#define CLASS_POSITION 6
#define SCORE_POSITION 5
#define NUM_COORDINATES 4
#define CONVERT_UINT8_FP32(x,offset,scale) ((CONVERT_TO_INT8(x) - offset) * scale) 

using bbox = std::vector<float>;
#include "nms_abp.hpp"

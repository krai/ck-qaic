//
// Copyright (c) 2018-2019 cTuning foundation.
// Copyright (c) 2019-2020 dividiti Limited.
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

#ifndef DETECT_SETTINGS_H
#define DETECT_SETTINGS_H

#include <fstream>
#include <iostream>
#include <list>
#include <map>
#include <sstream>
#include <stdlib.h>
#include <thread>
#include <vector>

/// Load mandatory string value from the environment.
inline std::string getenv_s(const std::string &name) {
  const char *value = getenv(name.c_str());
  if (!value) {
    throw std::runtime_error("Required environment variable " + name +
                             " is not set");
  }
  return std::string(value);
}

inline std::string getenv_opt_s(const std::string &name,
                                const std::string default_value) {
  const char *value = getenv(name.c_str());
  if (!value)
    return default_value;
  else
    return std::string(value);
}

/// Load mandatory integer value from the environment.
inline int getenv_i(const std::string &name) {
  const char *value = getenv(name.c_str());
  if (!value)
    throw std::runtime_error("Required environment variable " + name +
                             " is not set");
  return std::atoi(value);
}

/// Load mandatory float value from the environment.
inline float getenv_f(const std::string &name) {
  const char *value = getenv(name.c_str());
  if (!value)
    throw std::runtime_error("Required environment variable " + name +
                             " is not set");
  return std::atof(value);
}

/// Load an optional boolean value from the environment.
inline bool getenv_b(const char *name) {
  std::string value = getenv(name);

  return (value == "YES" || value == "yes" || value == "ON" || value == "on" ||
          value == "1");
}

template <typename T> std::string to_string(T value) {
  std::ostringstream os;
  os << value;
  return os.str();
}

struct FileInfo {
  std::string name;
  int width;
  int height;
};

template <char delimiter> class WordDelimitedBy : public std::string {};

template <char delimiter>
std::istream &operator>>(std::istream &is, WordDelimitedBy<delimiter> &output) {
  std::getline(is, output, delimiter);
  return is;
}

inline std::string alter_str(std::string a, std::string b) {
  return a != "" ? a : b;
};
inline std::string alter_str(char *a, std::string b) {
  return a != nullptr ? a : b;
};
inline std::string alter_str(char *a, char *b) { return a != nullptr ? a : b; };
inline int alter_str_i(char *a, int b) {
  return a != nullptr ? std::atoi(a) : b;
};
inline int alter_str_i(char *a, char *b) {
  return std::atoi(a != nullptr ? a : b);
};
inline int alter_str_i(std::string a, std::string b) {
  return std::atoi(a != "" ? a.c_str() : b.c_str());
};
//inline float alter_str_f(std::string a, std::string b) {
//  return std::atof(a != "" ? a.c_str() : b.c_str());
//};
inline float alter_str_f(const char *a, const char *b) {
  return std::atof(a != nullptr ? a : b);
};

std::string abs_path(std::string, std::string);
std::string str_to_lower(std::string);
std::string str_to_lower(char *);
bool get_yes_no(std::string);
bool get_yes_no(char *);
std::vector<std::string> *readClassesFile(std::string);

class BenchmarkSettings {
public:
  BenchmarkSettings() {

    std::cout << "MAX WAIT = " << max_wait << std::endl;

    try {
      std::string model_dataset_type =
          getenv_s("CK_ENV_ONNX_MODEL_DATASET_TYPE");
      if (model_dataset_type != "coco") {
        throw("Unsupported model dataset type: " + model_dataset_type);
      }

      std::stringstream ss_ids(qaic_hw_ids_str);
      while( ss_ids.good() )
      {
        std::string substr;
        std::getline( ss_ids, substr, ',' );
        qaic_hw_ids.push_back(std::stoi(substr));
      }
      qaic_device_count = qaic_hw_ids.size();

      std::string classes_file =
          abs_path(getenv_s("CK_ENV_QAIC_MODEL_ROOT"),
                   getenv_s("CK_ENV_ONNX_MODEL_FLATLABELS"));

      _nms_priors_bin_path = getenv_s("CK_ENV_QAIC_NMS_PRIORS_BIN_PATH");

      _model_classes = *readClassesFile(classes_file);
      _images_dir = getenv_s("CK_ENV_DATASET_OBJ_DETECTION_PREPROCESSED_DIR");
      _images_file =
          getenv_s("CK_ENV_DATASET_OBJ_DETECTION_PREPROCESSED_SUBSET_FOF");

      _image_size_height = getenv_i("ML_MODEL_IMAGE_HEIGHT");
      _image_size_width = getenv_i("ML_MODEL_IMAGE_WIDTH");
      _num_channels = alter_str_i(getenv("ML_MODEL_IMAGE_CHANNELS"), 3);

      _correct_background =
          get_yes_no(getenv("CK_ENV_QAIC_MODEL_NEED_BACKGROUND_CORRECTION"));

      //        _normalize_img =
      //        get_yes_no(getenv_s("ML_MODEL_NORMALIZE_DATA")); _subtract_mean
      //        = get_yes_no(getenv_s("CK_ENV_QAIC_MODEL_SUBTRACT_MEAN"));

      _batch_count = alter_str_i(getenv("CK_BATCH_COUNT"), 1);
      //_batch_size = alter_str_i(getenv("CK_BATCH_SIZE"), 1);
      _full_report = !get_yes_no(getenv("CK_SILENT_MODE"));
      verbosity_level = getenv_i("CK_VERBOSE");



      _m_max_detections = alter_str_i(
          getenv("MAX_DETECTIONS"), getenv("CK_ENV_QAIC_MODEL_MAX_DETECTIONS"));

      _m_num_classes = _model_classes.size();

      // Print settings
      if (verbosity_level || _full_report) {
        std::cout << "Graph file: " << _graph_file << std::endl;
        std::cout << "Image dir: " << _images_dir << std::endl;
        std::cout << "Image list: " << _images_file << std::endl;
        std::cout << "Image size: " << _image_size_width << "*"
                  << _image_size_height << std::endl;
        std::cout << "Image channels: " << _num_channels << std::endl;
        std::cout << "Batch count: " << _batch_count << std::endl;
        std::cout << "Batch size: " << _batch_size << std::endl;
        //            std::cout << "Normalize: " << _normalize_img << std::endl;
        //            std::cout << "Subtract mean: " << _subtract_mean <<
        //            std::endl;
      }

      // Load list of images to be processed
      std::ifstream file(_images_dir + "/" + _images_file);
      if (!file)
        throw "Unable to open image list file " + _images_file;

      for (std::string s; !getline(file, s).fail();) {
        std::istringstream iss(s);
        std::vector<std::string> row(
            (std::istream_iterator<WordDelimitedBy<';'>>(iss)),
            std::istream_iterator<WordDelimitedBy<';'>>());
        FileInfo fileInfo = {row[0], std::atoi(row[1].c_str()),
                             std::atoi(row[2].c_str())};
        _image_list.emplace_back(fileInfo);
      }
      if (verbosity_level || _full_report) {
        std::cout << "Image count in file: " << _image_list.size() << std::endl;
      }
    } catch (const std::runtime_error &e) {
      std::cout << "Exception during parameter setup: " << e.what()
                << std::endl;
      exit(1);
    } catch (const char *msg) {
      std::cout << "Exception message during parameter setup: " << msg
                << std::endl;
      exit(1);
    } catch (const std::string &s) {
      std::cout << "Exception message during parameter setup: " << s
                << std::endl;
      exit(1);
    }
  }

  const int get_verbosity_level() const { return verbosity_level; }

  const std::vector<FileInfo> &image_list() const { return _image_list; }
  const std::vector<FileInfo> &list_of_available_imagefiles() const {
    return _image_list;
  }

  const std::vector<std::string> &model_classes() const {
    return _model_classes;
  }

  int batch_count() { return _batch_count; }

  int batch_size() { return _batch_size; }

  int detections_buffer_size() { return _m_max_detections + 1; }

  int image_size_height() { return _image_size_height; }

  int image_size_width() { return _image_size_width; }

  int num_channels() { return _num_channels; }

  bool correct_background() { return _correct_background; }

  bool full_report() { return _full_report || verbosity_level; }

  bool normalize_img() { return _normalize_img; }

  bool subtract_mean() { return _subtract_mean; }

  bool verbose() { return verbosity_level; };

  int get_max_detections() { return _m_max_detections; };
  void set_max_detections(int i) { _m_max_detections = i; }

  int get_max_classes_per_detection() { return _m_max_classes_per_detection; };
  void set_max_classes_per_detection(int i) {
    _m_max_classes_per_detection = i;
  }

  int get_detections_per_class() { return _m_detections_per_class; };
  void set_detections_per_class(int i) { _m_detections_per_class = i; }

  int get_num_classes() { return _m_num_classes; };
  void set_num_classes(int i) { _m_num_classes = i; }

  std::string graph_file() { return _graph_file; }

  std::string images_dir() { return _images_dir; }

  std::string detections_out_dir() { return _detections_out_dir; }

  std::string nms_priors_bin_path() { return _nms_priors_bin_path; }

  const int images_in_memory_max = getenv_i("CK_LOADGEN_BUFFER_SIZE");
  const bool trigger_cold_run = getenv_b("CK_LOADGEN_TRIGGER_COLD_RUN");

public:
  const char *qaic_model_root = getenv("CK_ENV_QAIC_MODEL_ROOT");
  const bool has_background_class =
      getenv_s("ML_MODEL_HAS_BACKGROUND_CLASS") == "YES";
  // const int boxes_buff_idx = getenv_i("ML_MODEL_BOXES_BUFFER_IDX");
  // const int classes_buff_idx = getenv_i("ML_MODEL_CLASSES_BUFFER_IDX");
  // const int scores_buff_idx = getenv_i("ML_MODEL_SCORES_BUFFER_IDX");

  // defaults for hardware setup
  const int qaic_activation_count = alter_str_i(getenv("CK_ENV_QAIC_ACTIVATION_COUNT"), 1);
  const int qaic_set_size = alter_str_i(getenv("CK_ENV_QAIC_QUEUE_LENGTH"), 4);
  const int qaic_threads_per_queue = alter_str_i(getenv("CK_ENV_QAIC_THREADS_PER_QUEUE"), 4);
  const int output_count = getenv_i("CK_ENV_QAIC_OUTPUT_COUNT");
  const int qaic_batch_size = getenv_i("CK_ENV_QAIC_MODEL_BATCH_SIZE");
  std::string qaic_skip_stage =
      alter_str(getenv("CK_ENV_QAIC_SKIP_STAGE"), std::string(""));
  const float max_wait_rel = alter_str_f(getenv("CK_ENV_QAIC_MAX_WAIT_REL"), std::string("1.0").c_str());
  const int target_qps = alter_str_i(getenv("CK_LOADGEN_TARGET_QPS"), 1);
  int max_wait_tmp = max_wait_rel*(qaic_batch_size * 1000000) / target_qps;
  const int max_wait = alter_str_i(getenv("CK_ENV_QAIC_MAX_WAIT_ABS"), max_wait_tmp);

  const int verbosity_server = alter_str_i(getenv("CK_VERBOSE_SERVER"), 0);

  // choice of hardware
  std::string qaic_hw_ids_str = alter_str(getenv("CK_ENV_QAIC_DEVICE_IDS"), std::string("0"));
  std::vector<int> qaic_hw_ids;
  int qaic_device_count;

  const int input_select = alter_str_i(getenv("CK_ENV_QAIC_INPUT_SELECT"), 0);

  const int copy_threads_per_device = alter_str_i(getenv("CK_ENV_COPY_THREADS_PER_DEVICE"), 2);

  int verbosity_level;

  const float abc_classt = alter_str_f(getenv("CK_ENV_ABC_CLASST"), std::string("0.05").c_str());
  const float abc_nmst = alter_str_f(getenv("CK_ENV_ABC_NMST"), std::string("0.5").c_str());
  const float abc_loc_offset = alter_str_f(getenv("CK_ENV_ABC_LOC_OFFSET"), std::string("0.0").c_str());
  const float abc_loc_scale = alter_str_f(getenv("CK_ENV_ABC_LOC_SCALE"), std::string("0.136092901").c_str());
  const float abc_conf_offset = alter_str_f(getenv("CK_ENV_ABC_CONF_OFFSET"), std::string("0.0").c_str());
  const float abc_conf_scale = alter_str_f(getenv("CK_ENV_ABC_CONF_SCALE"), std::string("1.0").c_str());

  const int abc_max_dets_per_image = alter_str_i(getenv("CK_ENV_ABC_MAX_DETS_PER_IMAGE"), 100);
  const int abc_max_boxes_per_class = alter_str_i(getenv("CK_ENV_ABC_MAX_BOXES_PER_CLASS"), 100);

private:
  std::string _detections_out_dir;
  std::string _graph_file;
  std::string _images_dir;
  std::string _images_file;
  std::vector<FileInfo> _image_list;
  std::vector<std::string> _model_classes;

  std::string _nms_priors_bin_path;

  int _batch_count;
  int _batch_size;
  int _image_size_height;
  int _image_size_width;
  int _num_channels;
  int _number_of_threads;
  int _m_max_classes_per_detection;
  int _m_max_detections;
  int _m_detections_per_class;
  int _m_num_classes;

  bool _correct_background;
  bool _full_report;
  bool _normalize_img;
  bool _subtract_mean;

};

std::vector<std::string> *readClassesFile(std::string filename) {
  std::vector<std::string> *lines = new std::vector<std::string>;
  lines->clear();
  std::ifstream file(filename);
  std::string s;
  while (getline(file, s))
    lines->push_back(s);

  return lines;
}

bool get_yes_no(std::string answer) {
  std::locale loc;
  for (std::string::size_type i = 0; i < answer.length(); ++i)
    answer[i] = std::tolower(answer[i], loc);
  if (answer == "1" || answer == "yes" || answer == "on" || answer == "true")
    return true;
  return false;
}
bool get_yes_no(char *answer) {
  if (answer == nullptr)
    return false;
  return get_yes_no(std::string(answer));
}

std::string str_to_lower(std::string answer) {
  std::locale loc;
  for (std::string::size_type i = 0; i < answer.length(); ++i)
    answer[i] = std::tolower(answer[i], loc);
  return answer;
}

std::string str_to_lower(char *answer) {
  return str_to_lower(std::string(answer));
}

std::string abs_path(std::string path_name, std::string file_name) {
#ifdef _WIN32
  std::string delimiter = "\\";
#else
  std::string delimiter = "/";
#endif
  if (path_name.back() == '\\' || path_name.back() == '/') {
    return path_name + file_name;
  }
  return path_name + delimiter + file_name;
}

#endif // DETECT_SETTINGS_H

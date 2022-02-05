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

#pragma once

#include <stdio.h>
#include <stdlib.h>

#include <assert.h>
#include <dirent.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string.h>
#include <vector>

#define DEBUG(msg) std::cout << "DEBUG: " << msg << std::endl;

namespace CK {

/// Load mandatory string value from the environment.
inline std::string getenv_s(const std::string &name) {
  const char *value = getenv(name.c_str());
  if (!value)
    throw "Required environment variable " + name + " is not set";
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
    throw "Required environment variable " + name + " is not set";
  return atoi(value);
}

/// Load mandatory float value from the environment.
inline float getenv_f(const std::string &name) {
  const char *value = getenv(name.c_str());
  if (!value)
    throw "Required environment variable " + name + " is not set";
  return atof(value);
}

/// Load an optional boolean value from the environment.
inline bool getenv_b(const char *name) {
  std::string value = getenv(name);

  return (value == "YES" || value == "yes" || value == "ON" || value == "on" ||
          value == "1");
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

/// Dummy `sprintf` like formatting function using std::string.
/// It uses buffer of fixed length so can't be used in any cases,
/// generally use it for short messages with numeric arguments.
template <typename... Args>
inline std::string format(const char *str, Args... args) {
  char buf[1024];
  sprintf(buf, str, args...);
  return std::string(buf);
}

//----------------------------------------------------------------------

class Accumulator {
public:
  void reset() { _total = 0, _count = 0; }
  void add(float value) { _total += value, _count++; }
  float total() const { return _total; }
  float avg() const { return _total / static_cast<float>(_count); }

private:
  float _total = 0;
  int _count = 0;
};

//----------------------------------------------------------------------

class BenchmarkSettings {
public:
  const std::string images_dir =
      getenv_s("CK_ENV_DATASET_IMAGENET_PREPROCESSED_DIR");
  const std::string available_images_file =
      getenv_s("CK_ENV_DATASET_IMAGENET_PREPROCESSED_SUBSET_FOF");
  const bool skip_internal_preprocessing =
      getenv("CK_ENV_DATASET_IMAGENET_PREPROCESSED_DATA_TYPE") &&
      (getenv_s("CK_ENV_DATASET_IMAGENET_PREPROCESSED_DATA_TYPE") == "float32");

  const std::string result_dir = getenv_s("CK_RESULTS_DIR");
  // const std::string input_layer_name =
  // getenv_s("CK_ENV_TENSORFLOW_MODEL_INPUT_LAYER_NAME");
  // const std::string output_layer_name =
  // getenv_s("CK_ENV_TENSORFLOW_MODEL_OUTPUT_LAYER_NAME");
  const int images_in_memory_max = getenv_i("CK_LOADGEN_BUFFER_SIZE");
  const int image_size =
      getenv_i("CK_ENV_DATASET_IMAGENET_PREPROCESSED_INPUT_SQUARE_SIDE");
  const int num_channels = 3;
  const int num_classes = 1000;
  const bool normalize_img =
      false; // getenv_s("CK_ENV_QAIC_MODEL_NORMALIZE_DATA") == "YES";

  const bool subtract_mean =
      false; // getenv_opt_s("CK_ENV_QAIC_MODEL_SUBTRACT_MEAN", "0") == "YES";

  const char *given_channel_means_str = getenv("ML_MODEL_GIVEN_CHANNEL_MEANS");
  const bool isNHWC = getenv_s("ML_MODEL_DATA_LAYOUT") == "NHWC";

  const bool trigger_cold_run = getenv_b("CK_LOADGEN_TRIGGER_COLD_RUN");

  const int verbosity_level = getenv_i("CK_VERBOSE");

  const int verbosity_server = alter_str_i(getenv("CK_VERBOSE_SERVER"), 0);

  const char *qaic_model_root = getenv("CK_ENV_QAIC_MODEL_ROOT");
  const bool has_background_class =
      getenv_s("ML_MODEL_HAS_BACKGROUND_CLASS") == "YES";

  // defaults for hardware setup
  const int qaic_activation_count =
      alter_str_i(getenv("CK_ENV_QAIC_ACTIVATION_COUNT"), 1);
  const int qaic_set_size = alter_str_i(getenv("CK_ENV_QAIC_QUEUE_LENGTH"), 4);
  const int qaic_threads_per_queue =
      alter_str_i(getenv("CK_ENV_QAIC_THREADS_PER_QUEUE"), 4);
  const int output_count = getenv_i("CK_ENV_QAIC_OUTPUT_COUNT");
  const int qaic_batch_size = getenv_i("CK_ENV_QAIC_MODEL_BATCH_SIZE");
  std::string qaic_skip_stage =
      alter_str(getenv("CK_ENV_QAIC_SKIP_STAGE"), std::string(""));
  const float max_wait_rel = alter_str_f(getenv("CK_ENV_QAIC_MAX_WAIT_REL"), std::string("1.0").c_str());
  const int target_qps = alter_str_i(getenv("CK_LOADGEN_TARGET_QPS"), 1);
  int max_wait_tmp = max_wait_rel*(qaic_batch_size * 1000000) / target_qps;
  const int max_wait = alter_str_i(getenv("CK_ENV_QAIC_MAX_WAIT_ABS"), max_wait_tmp);


  // choice of hardware
  std::string qaic_hw_ids_str =
      alter_str(getenv("CK_ENV_QAIC_DEVICE_IDS"), std::string("0"));
  std::vector<int> qaic_hw_ids;
  int qaic_device_count;

  const int input_select = alter_str_i(getenv("CK_ENV_QAIC_INPUT_SELECT"), 0);
  
  const int num_setup_threads = alter_str_i(getenv("CK_ENV_NUM_SETUP_THREADS"), 2);

  BenchmarkSettings() {

    std::cout << "MAX WAIT = " << max_wait << std::endl;

    if (given_channel_means_str) {
      std::stringstream ss(given_channel_means_str);
      for (int i = 0; i < 3; i++) {
        ss >> given_channel_means[i];
      }
    }

    std::stringstream ss_ids(qaic_hw_ids_str);
    while (ss_ids.good()) {
      std::string substr;
      std::getline(ss_ids, substr, ',');
      qaic_hw_ids.push_back(std::stoi(substr));
    }
    qaic_device_count = qaic_hw_ids.size();

    _number_of_threads = std::thread::hardware_concurrency();
    _number_of_threads = _number_of_threads < 1 ? 1 : _number_of_threads;
    _number_of_threads = !getenv("CK_HOST_CPU_NUMBER_OF_PROCESSORS")
                             ? _number_of_threads
                             : getenv_i("CK_HOST_CPU_NUMBER_OF_PROCESSORS");

    // Print settings
    std::cout << "Graph file: " << _graph_file << std::endl;
    std::cout << "Image dir: " << images_dir << std::endl;
    std::cout << "Image list: " << available_images_file << std::endl;
    std::cout << "Image size: " << image_size << std::endl;
    std::cout << "Image channels: " << num_channels << std::endl;
    std::cout << "Prediction classes: " << num_classes << std::endl;
    std::cout << "Result dir: " << result_dir << std::endl;
    std::cout << "How many images fit in memory buffer: "
              << images_in_memory_max << std::endl;
    std::cout << "Normalize: " << normalize_img << std::endl;
    std::cout << "Subtract mean: " << subtract_mean << std::endl;
    if (subtract_mean && given_channel_means_str)
      std::cout << "Per-channel means to subtract: " << given_channel_means[0]
                << ", " << given_channel_means[1] << ", "
                << given_channel_means[2] << std::endl;

    // Create results dir if none
    auto dir = opendir(result_dir.c_str());
    if (dir)
      closedir(dir);
    else
      system(("mkdir " + result_dir).c_str());

    // Load list of images to be processed
    std::ifstream file(available_images_file);
    if (!file)
      throw "Unable to open the available image list file " +
          available_images_file;
    for (std::string s; !getline(file, s).fail();)
      _available_image_list.emplace_back(s);
    std::cout << "Number of available imagefiles: "
              << _available_image_list.size() << std::endl;
  }

  const std::vector<std::string> &list_of_available_imagefiles() const {
    return _available_image_list;
  }

  std::vector<std::string> _available_image_list;

  int number_of_threads() { return _number_of_threads; }

  std::string graph_file() { return _graph_file; }

  float given_channel_means[3];

private:
  int _number_of_threads;
  std::string _graph_file;
};

}; // namespace CK
#endif

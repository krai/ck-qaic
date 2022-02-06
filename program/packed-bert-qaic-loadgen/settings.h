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

  const std::string squad_dataset_tokenized_path =
      getenv_s("CK_ENV_DATASET_SQUAD_TOKENIZED_ROOT");

  const std::string input_ids   = squad_dataset_tokenized_path + "/" + getenv_s("CK_ENV_DATASET_SQUAD_TOKENIZED_INPUT_IDS");
  const std::string input_mask  = squad_dataset_tokenized_path + "/" + getenv_s("CK_ENV_DATASET_SQUAD_TOKENIZED_INPUT_MASK");
  const std::string segment_ids = squad_dataset_tokenized_path + "/" + getenv_s("CK_ENV_DATASET_SQUAD_TOKENIZED_SEGMENT_IDS");

  const int max_seq_length =
      getenv_i("CK_ENV_DATASET_SQUAD_TOKENIZED_MAX_SEQ_LENGTH");

  const std::string result_dir = getenv_s("CK_RESULTS_DIR");
  const int inputs_in_memory_max = getenv_i("CK_LOADGEN_BUFFER_SIZE");
  const int dataset_size = getenv_i("CK_LOADGEN_DATASET_SIZE");

  const bool trigger_cold_run = getenv_b("CK_LOADGEN_TRIGGER_COLD_RUN");

  const int verbosity_level = getenv_i("CK_VERBOSE");

  const int verbosity_server = alter_str_i(getenv("CK_VERBOSE_SERVER"), 0);

  const char *qaic_model_root = getenv("CK_ENV_QAIC_MODEL_ROOT");

  // defaults for hardware setup
  const int qaic_activation_count =
      alter_str_i(getenv("CK_ENV_QAIC_ACTIVATION_COUNT"), 1);
  const int qaic_set_size = alter_str_i(getenv("CK_ENV_QAIC_QUEUE_LENGTH"), 4);
  const int qaic_threads_per_queue =
      alter_str_i(getenv("CK_ENV_QAIC_THREADS_PER_QUEUE"), 4);
  const int output_count = 2;
  const int input_count = 4;
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
  const int num_setup_threads =
      alter_str_i(getenv("CK_ENV_NUM_SETUP_THREADS"), 2);

  BenchmarkSettings() {

    std::cout << "MAX WAIT: " << max_wait << std::endl;

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

    // Create results dir if none
    auto dir = opendir(result_dir.c_str());
    if (dir)
      closedir(dir);
    else
      system(("mkdir " + result_dir).c_str());
  }

  int get_input_count() const {
    return dataset_size;
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

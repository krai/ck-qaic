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

#ifndef BENCHMARK_H
#define BENCHMARK_H

#pragma once

#include <stdio.h>
#include <stdlib.h>

#include <iterator>
#include <algorithm>
#include <chrono>
#include <cwctype>
#include <dirent.h>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <locale>
#include <map>
#include <memory>
#include <string.h>
#include <vector>

#include <xopenme.h>

#include "settings.h"

#include "NMS_ABP/CLASS_SPECIFIC_NMS/include/AnchorBoxSSD.hpp"

#define DEBUG(msg) std::cout << "DEBUG: " << msg << std::endl;

namespace CK {

//----------------------------------------------------------------------

class BenchmarkSession {
public:
  BenchmarkSession(BenchmarkSettings *settings) : _settings(settings) {}

  virtual ~BenchmarkSession() {}

  const std::vector<std::string> &
  load_filenames(std::vector<size_t> img_indices) {
    _filenames_buffer.clear();
    _filenames_buffer.reserve(img_indices.size());
    idx2loc.clear();

    auto list_of_available_imagefiles =
        _settings->list_of_available_imagefiles();
    auto count_available_imagefiles = list_of_available_imagefiles.size();

    int loc = 0;
    for (auto idx : img_indices) {
      if (idx < count_available_imagefiles) {
        _filenames_buffer.emplace_back(list_of_available_imagefiles[idx].name);
        idx2loc[idx] = loc++;
      } else {
        std::cerr << "Trying to load filename[" << idx << "] when only "
                  << count_available_imagefiles << " images are available"
                  << std::endl;
        exit(1);
      }
    }

    return _filenames_buffer;
  }

  const std::vector<std::string> &current_filenames() const {
    return _filenames_buffer;
  }

  std::map<int, int> idx2loc;

private:
  BenchmarkSettings *_settings;
  std::vector<std::string> _filenames_buffer;
};

//----------------------------------------------------------------------

template <typename TData> class StaticBuffer {
public:
  StaticBuffer(int size, const std::string &dir, TData *ptr = NULL)
      : _size(size), _dir(dir) {
    if (!ptr)
      _buffer = (TData *)aligned_alloc(32, size);
    //_buffer = new TData[size];
    else
      _buffer = ptr;
  }

  virtual ~StaticBuffer() { delete[] _buffer; }

  TData *data() const { return _buffer; }
  int size() const { return _size; }

protected:
  const int _size;
  const std::string _dir;
  TData *_buffer;
};

//----------------------------------------------------------------------

class ImageData : public StaticBuffer<uint8_t> {
public:
  ImageData(BenchmarkSettings *s, uint8_t *buf = NULL)
      : StaticBuffer(s->image_size_height() * s->image_size_width() *
                         s->num_channels() *
                         ((s->qaic_skip_stage != "convert") ? sizeof(float)
                                                            : sizeof(uint8_t)),
                     s->images_dir(), buf),
        s(s) {}

  void load(const std::string &filename, int vl) {
    auto path = _dir + '/' + filename;
    std::ifstream file(path, std::ios::in | std::ios::binary);
    if (!file)
      throw "Failed to open image data " + path;

    file.read(reinterpret_cast<char *>(_buffer), _size * sizeof(uint8_t));
  }

private:
  BenchmarkSettings *s;
};

//----------------------------------------------------------------------

class ResultData {
public:
  ResultData(BenchmarkSettings *s) : _size(0) {
    _buffer = new float[s->detections_buffer_size() * 7];
  }

  ~ResultData() { delete[] _buffer; }

  int size() const { return _size; }

  void set_size(int size) { _size = size; }

  float *data() const { return _buffer; }

private:
  float *_buffer;
  int _size;
};

//----------------------------------------------------------------------

class IBenchmark {
public:
  bool has_background_class = false;

  virtual ~IBenchmark() {}
  virtual void load_images(BenchmarkSession *session) = 0;
  virtual void unload_images(size_t num_examples) = 0;
  virtual void get_next_results(std::vector<int> &image_idxs,
                                std::vector<ResultData *> &results, int dev_idx,
                                int act_idx, int set_idx) = 0;
  virtual void
  get_random_images(const std::vector<mlperf::QuerySample> &samples,
                    int dev_idx, int act_idx, int set_idx) = 0;

  virtual void *get_img_ptr(int dev_idx, int img_idx) = 0;
};

template <typename TInConverter, typename TOutConverter,
          typename TInputDataType, typename TOutput1DataType,
          typename TOutput2DataType>
class Benchmark : public IBenchmark {
public:
  void initResultsBuffer(int dev_id) {
    for (int d = 0; d < _settings->qaic_device_count; ++d) {
      nms_results[d].resize(_settings->qaic_activation_count);
      reformatted_results[d].resize(_settings->qaic_activation_count);
      for (int a = 0; a < _settings->qaic_activation_count; ++a) {
        nms_results[d][a].resize(_settings->qaic_set_size);
        reformatted_results[d][a].resize(_settings->qaic_set_size);
        for (int s = 0; s < _settings->qaic_set_size; ++s) {
          nms_results[d][a][s] = std::vector<std::vector<float> >(
              0, std::vector<float>(NUM_COORDINATES + 2, 0));
          for (int b = 0; b <  _settings->qaic_batch_size; b++) {
            reformatted_results[d][a][s].push_back(new ResultData(_settings));
          }
        }
      }
    }
  }
  Benchmark(
      BenchmarkSettings *settings,
      std::vector<std::vector<std::vector<void *> > > &in_ptrs,
      std::vector<std::vector<std::vector<std::vector<void *> > > > &out_ptrs)
      : _settings(settings) {
    _in_ptrs = in_ptrs;
    _out_ptrs = out_ptrs;
    _in_converter.reset(new TInConverter(settings));
    _out_converter.reset(new TOutConverter(settings));
    int dev_cnt = settings->qaic_device_count;
    _in_batch.resize(dev_cnt);
    _out_batch.resize(dev_cnt);
    // load NMS data

    acConfig.classT = settings->abc_classt;
    acConfig.nmsT = settings->abc_nmst;
    acConfig.maxDetectionsPerImage = settings->abc_max_dets_per_image;
    acConfig.maxBoxesPerClass = settings->abc_max_boxes_per_class;

    // Set the scale and offset from network Destriptors
    acConfig.locOffset = settings->abc_loc_offset;
    // acConfig.locScale = 0.135993376;
    acConfig.locScale = settings->abc_loc_scale; // aimet mixed
    acConfig.confOffset = settings->abc_conf_offset;
    acConfig.confScale = settings->abc_conf_scale;

    acConfig.priorfilename = _settings->nms_priors_bin_path();

    /*
    std::cout << acConfig.classT << std::endl;
    std::cout << acConfig.nmsT << std::endl;
    std::cout << acConfig.maxDetectionsPerImage << std::endl;
    std::cout << acConfig.maxBoxesPerClass << std::endl;
    std::cout << acConfig.locOffset << std::endl;
    std::cout << acConfig.locScale << std::endl;
    std::cout << acConfig.confOffset << std::endl;
    std::cout << acConfig.confScale << std::endl;
    std::cout << acConfig.priorfilename << std::endl;
    */

    nwOutputLayer = new AnchorBoxProc(acConfig);

    // create buffers for each of the available threads
    nms_results.resize(settings->qaic_device_count);
    reformatted_results.resize(settings->qaic_device_count);

    for (int dev_idx = 0; dev_idx < settings->qaic_device_count; ++dev_idx) {
      std::thread t(&Benchmark::initResultsBuffer, this, dev_idx);
#ifdef G292
      unsigned coreid = (dev_idx > 7) ? -64 + dev_idx * 8 : 64 + dev_idx * 8;
      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(coreid, &cpuset);
      pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
#endif
      t.join();
    }
    const int CTN = settings->copy_threads_per_device;
    get_next_results_image_idxs.resize(CTN * dev_cnt);
    get_next_results_results.resize(CTN * dev_cnt);
    get_next_results_act_idx.resize(CTN * dev_cnt);
    get_next_results_set_idx.resize(CTN * dev_cnt);
    get_next_results_finished.resize(CTN * dev_cnt);
    get_next_results_turn.resize(dev_cnt);

    for (int dev_idx = 0; dev_idx < settings->qaic_device_count; ++dev_idx) {
      get_next_results_turn[dev_idx] = 0;
      for (int i = 0; i < CTN; i++) {
        get_next_results_mutex[dev_idx + i * dev_cnt].lock();
        std::thread t(&Benchmark::get_next_results_worker, this,
                      dev_idx + i * dev_cnt);

#ifdef G292
        unsigned coreid = (dev_idx > 7) ? -64 + dev_idx * 8 : 64 + dev_idx * 8;
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(coreid + i, &cpuset);
        pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
#endif
        t.detach();
      }
    }

#ifdef MODEL_R34
    std::vector<int> exclude{ 12, 26, 29, 30, 45, 66, 68, 69, 71, 83 };
#else
    std::vector<int> exclude{};
#endif

    for (int i = 0; i < 100; ++i)
      if (std::find(exclude.begin(), exclude.end(), i) == exclude.end())
        class_map.push_back(i);
  }

  ~Benchmark() {
    for (int d = 0; d < _settings->qaic_device_count; ++d)
      for (int a = 0; a < _settings->qaic_activation_count; ++a)
        for (int s = 0; s < _settings->qaic_set_size; ++s)
          for (int b = 0; b <  _settings->qaic_batch_size; b++)
            delete reformatted_results[d][a][s][b];
  }
  /*
   void load_images(BenchmarkSession *_session) override {
      session = _session;
      auto vl = _settings->verbosity_level;

      const std::vector<std::string> &image_filenames =
          session->current_filenames();

      int length = image_filenames.size();
      _current_buffer_size = length;
      _in_batch[0] = new std::unique_ptr<ImageData>[length];
      _out_batch[0] = new std::unique_ptr<ResultData>[length];
      int i = 0;
      for (auto image_file : image_filenames) {
        _in_batch[0][i].reset(new ImageData(_settings));
        _out_batch[0][i].reset(new ResultData(_settings));
        _in_batch[0][i]->load(image_file, vl);
        i++;
      }
    }*/
  void load_images_locally(int d) {
    auto vl = _settings->verbosity_level;

    const std::vector<std::string> &image_filenames =
        session->current_filenames();

    unsigned length = image_filenames.size();
    _current_buffer_size = length;
    _in_batch[d] = new std::unique_ptr<ImageData>[length];
    _out_batch[d] = new std::unique_ptr<ResultData>[length];
    unsigned batch_size = _settings->qaic_batch_size;
    unsigned image_size = _settings->image_size_width() *
                          _settings->image_size_height() *
                          _settings->num_channels() * sizeof(TInputDataType);
    for (int i = 0; i < length; i += batch_size) {
      unsigned actual_batch_size =
          std::min(batch_size, batch_size < length ? (length - i) : length);
      uint8_t *buf = (uint8_t *)aligned_alloc(32, batch_size * image_size);
      for (auto j = 0; j < actual_batch_size; j++, buf += image_size) {
        _in_batch[d][i + j].reset(new ImageData(_settings, buf));
        _out_batch[d][i + j].reset(new ResultData(_settings));
        _in_batch[d][i + j]->load(image_filenames[i + j], vl);
      }
    }
  }

  void load_images(BenchmarkSession *_session) override {
    session = _session;
#ifdef G292
    int i = 64;
    for (int dev_idx = 0; dev_idx < _settings->qaic_device_count; ++dev_idx) {
      std::thread t(&Benchmark::load_images_locally, this, dev_idx);

      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(i + dev_idx * 8, &cpuset);
      // CPU_SET(i+dev_idx*8+4, &cpuset);
      if (dev_idx == 7)
        i = -64;
      pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);

      t.join();
    }
#else
    load_images_locally(0);

#endif
  }

  void unload_images(size_t num_examples) override {
    uint16_t batch_size = _settings->qaic_batch_size;
#ifdef G292
    int N = _settings->qaic_device_count;
#else
    int N = 1;
#endif
    for (int dev_idx = 0; dev_idx < N; ++dev_idx) {
      for (size_t i = 0; i < num_examples; i += batch_size) {
        delete _in_batch[dev_idx][i].get();
        delete _out_batch[dev_idx][i].get();
      }
    }
  }

  void get_random_images(const std::vector<mlperf::QuerySample> &samples,
                         int dev_idx, int act_idx, int set_idx) override {
    for (int i = 0; i < samples.size(); ++i) {
      TInputDataType *ptr =
          ((TInputDataType *)_in_ptrs[dev_idx][act_idx][set_idx]) +
          i * _settings->image_size_width() * _settings->image_size_height() *
              _settings->num_channels();
      _in_converter->convert(
          _in_batch[dev_idx][session->idx2loc[samples[i].index]].get(), ptr);
    }
  }

  virtual void *get_img_ptr(int dev_idx, int img_idx) {
#ifndef G292
    return _in_batch[0][session->idx2loc[img_idx]].get()->data();
#else
    return _in_batch[dev_idx][session->idx2loc[img_idx]].get()->data();
#endif
  }

  void get_next_results_worker(int fake_idx) {

    int dev_cnt = _settings->qaic_device_count;
    int dev_idx = fake_idx;
    while (dev_idx - dev_cnt >= 0)
      dev_idx -= dev_cnt;
    while (true) {
      get_next_results_mutex[fake_idx].lock();
      const std::vector<int> &image_idxs =
          *get_next_results_image_idxs[fake_idx];
      std::vector<ResultData *> &results = *get_next_results_results[fake_idx];

      const int act_idx = get_next_results_act_idx[fake_idx];
      const int set_idx = get_next_results_set_idx[fake_idx];

      results.clear();

      TOutput1DataType *boxes_ptr =
          (TOutput1DataType *)_out_ptrs[dev_idx][act_idx][set_idx][BOXES_INDEX];
      TOutput2DataType *classes_ptr = (TOutput2DataType *)
          _out_ptrs[dev_idx][act_idx][set_idx][CLASSES_INDEX];

      // This could be threaded to match batch size
      for (int i = 0; i < image_idxs.size(); ++i) {
        nms_results[dev_idx][act_idx][set_idx].clear();

        // get pointers to unique buffer for device->activation->set
        std::vector<std::vector<float> > &nms_res =
            nms_results[dev_idx][act_idx][set_idx];
        ResultData *next_result_ptr =
            reformatted_results[dev_idx][act_idx][set_idx][i];
        TOutput1DataType *dataLoc =
            boxes_ptr + i * TOTAL_NUM_BOXES * NUM_COORDINATES;
        TOutput2DataType *dataConf =
            classes_ptr + i * TOTAL_NUM_BOXES * NUM_CLASSES;

        float idx = image_idxs[i];
        if (_settings->qaic_skip_stage != "convert") {
          anchor::fTensor tLoc =
              anchor::fTensor({ "tLoc", { TOTAL_NUM_BOXES, NUM_COORDINATES },
                                (float *)dataLoc });
          anchor::fTensor tConf = anchor::fTensor(
              { "tConf", { TOTAL_NUM_BOXES, NUM_CLASSES }, (float *)dataConf });
          nwOutputLayer->anchorBoxProcessingFloatPerBatch(
              std::ref(tLoc), std::ref(tConf), std::ref(nms_res), idx);
        } else {
          anchor::uTensor tLoc =
              anchor::uTensor({ "tLoc", { TOTAL_NUM_BOXES, NUM_COORDINATES },
                                (uint8_t *)dataLoc });
#ifdef MODEL_R34
          anchor::hfTensor tConf =
              anchor::hfTensor({ "tConf", { TOTAL_NUM_BOXES, NUM_CLASSES },
                                 (uint16_t *)dataConf });
          nwOutputLayer->anchorBoxProcessingUint8Float16PerBatch(
              std::ref(tLoc), std::ref(tConf), std::ref(nms_res), idx);
#else
          anchor::uTensor tConf =
              anchor::uTensor({ "tConf", { TOTAL_NUM_BOXES, NUM_CLASSES },
                                (uint8_t *)dataConf });
          nwOutputLayer->anchorBoxProcessingUint8PerBatch(
              std::ref(tLoc), std::ref(tConf), std::ref(nms_res), idx);
#endif
        }

        int num_elems = nms_res.size() < _settings->detections_buffer_size()
                            ? nms_res.size()
                            : _settings->detections_buffer_size();

        next_result_ptr->set_size(num_elems * 7);
        float *buffer = next_result_ptr->data();

        for (int j = 0; j < num_elems; j++) {
          buffer[0] = nms_res[j][0];
          buffer[1] = nms_res[j][1];
          buffer[2] = nms_res[j][2];
          buffer[3] = nms_res[j][3];
          buffer[4] = nms_res[j][4];
          buffer[5] = nms_res[j][5];
          buffer[6] = nms_res[j][6];

          buffer += 7;
        }

        _out_buffer_index %= _current_buffer_size;
        results.push_back(next_result_ptr);
      }
      get_next_results_finished[fake_idx] = true;
      get_next_results_mutex2[fake_idx].unlock();
    }
  }

  void get_next_results(std::vector<int> &image_idxs,
                        std::vector<ResultData *> &results, int dev_idx,
                        int act_idx, int set_idx) override {
    int dev_cnt = _settings->qaic_device_count;
    const int CTN = _settings->copy_threads_per_device;
    get_next_results_mutex3[dev_idx].lock();
    const int turn = (get_next_results_turn[dev_idx] + 1) % CTN;
    const int fake_idx = turn * dev_cnt + dev_idx;
    get_next_results_turn[dev_idx] = turn;
    get_next_results_mutex3[dev_idx].unlock();
    get_next_results_mutex2[fake_idx].lock();
    get_next_results_image_idxs[fake_idx] = &image_idxs;
    get_next_results_results[fake_idx] = &results;
    get_next_results_act_idx[fake_idx] = act_idx;
    get_next_results_set_idx[fake_idx] = set_idx;

    get_next_results_finished[fake_idx] = false;
    get_next_results_mutex[fake_idx].unlock();
    while (true) {
      if (get_next_results_finished[fake_idx])
        return;
      std::this_thread::sleep_for(std::chrono::nanoseconds(1));
    }
  }

private:
  BenchmarkSettings *_settings;
  BenchmarkSession *session;

  int _out_buffer_index = 0;
  int _current_buffer_size = 0;

  std::vector<std::vector<std::vector<void *> > > _in_ptrs;
  std::vector<std::vector<std::vector<std::vector<void *> > > > _out_ptrs;

  std::vector<std::unique_ptr<ImageData> *> _in_batch;
  std::vector<std::unique_ptr<ResultData> *> _out_batch;

  std::unique_ptr<TInConverter> _in_converter;
  std::unique_ptr<TOutConverter> _out_converter;

  AnchorBoxProc *nwOutputLayer;
  AnchorBoxConfig acConfig;

  std::vector<int> class_map;

  std::vector<std::vector<std::vector<std::vector<std::vector<float> > > > >
  nms_results;
  std::vector<std::vector<std::vector<std::vector<ResultData *> > > > reformatted_results;

  std::mutex get_next_results_mutex[256];
  std::mutex get_next_results_mutex2[256];
  std::mutex get_next_results_mutex3[16];

  std::vector<std::vector<int> *> get_next_results_image_idxs;
  std::vector<std::vector<ResultData *> *> get_next_results_results;

  std::vector<int> get_next_results_act_idx;
  std::vector<int> get_next_results_set_idx;
  std::vector<int> get_next_results_finished;
  std::vector<int> get_next_results_turn;
};

//----------------------------------------------------------------------

class IinputConverter {
public:
  virtual ~IinputConverter() {}
  virtual void convert(ImageData *source, void *target) = 0;
};

//----------------------------------------------------------------------

class InCopy : public IinputConverter {
public:
  InCopy(BenchmarkSettings *s) {}

  void convert(ImageData *source, void *target) {
    uint8_t *uint8_target = static_cast<uint8_t *>(target);
    memcpy(uint8_target, source->data(), source->size() * sizeof(uint8_t));
  }
};

//----------------------------------------------------------------------

class OutCopy {
public:
  OutCopy(BenchmarkSettings *s) : _settings(s) {

    std::vector<int> exclude{ 12, 26, 29, 30, 45, 66, 68, 69, 71, 83 };

    for (int i = 0; i < 100; ++i)
      if (std::find(exclude.begin(), exclude.end(), i) == exclude.end())
        class_map.push_back(i);
  }

  void convert(int img_idx, const float *boxes, const int64_t *classes,
               const float *scores, const int num, ResultData *target,
               int src_width, int src_height,
               std::vector<std::string> model_classes,
               bool correct_background) const {

    float *buffer = target->data();
    target->set_size(num * 7);

    auto img_data = _settings->list_of_available_imagefiles()[img_idx];

    // std::cout << src_width << " " << src_height << " " << img_data.width << "
    // " << img_data.height << std::endl;

    for (int i = 0; i < num; i++) {
      buffer[0] = img_idx;
      buffer[1] = boxes[i * 4];
      buffer[2] = boxes[i * 4 + 1];
      buffer[3] = boxes[i * 4 + 2];
      buffer[4] = boxes[i * 4 + 3];
      buffer[5] = scores[i];
      buffer[6] = class_map[int(classes[i])];

      if (i < 5)
        std::cout << buffer[0] << " " << buffer[1] << " " << buffer[2] << " "
                  << buffer[3] << " " << buffer[4] << " " << buffer[5] << " "
                  << class_map[int(classes[i])] << std::endl;

      buffer += 7;
    }
  }

private:
  BenchmarkSettings *_settings;
  std::vector<int> class_map;
};

} // namespace CK

#endif

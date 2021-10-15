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

#if defined(__amd64__) && defined(ENABLE_ZEN2)
#include <immintrin.h>
#include <cstdint>
#endif

#include <xopenme.h>

#include "settings.h"

#include "NMS_ABP/CLASS_SPECIFIC_NMS/include/AnchorBoxSSD.hpp"

#include "affinity.h"

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
          for (int b = 0; b <  _settings->qaic_batch_size; b++) {
            nms_results[d][a][s].push_back(std::vector<std::vector<float> >(
              0, std::vector<float>(NUM_COORDINATES + 2, 0)));
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
#if defined(G292) || defined(R282)
    if(settings -> input_select == 0) {
      unsigned OFFSET = 0;
      const int CTN = settings -> copy_threads_per_device;
      get_random_images_samples.resize(CTN*dev_cnt);
      get_random_images_act_idx.resize(CTN*dev_cnt);
      get_random_images_set_idx.resize(CTN*dev_cnt);
      get_random_images_finished.resize(CTN*dev_cnt);
      get_random_images_turn.resize(dev_cnt);
    
      for (int dev_idx = 0; dev_idx < dev_cnt; ++dev_idx) {
        get_random_images_turn[dev_idx]=0;
#ifdef R282
        if(dev_idx == 4) OFFSET = 4;
#endif
  
        unsigned coreid = OFFSET + ((dev_idx > 7) ? -(START_CORE) + dev_idx * 8 : (START_CORE) + dev_idx * 8);
        for (int i = 0; i < CTN; i++) {
          cpu_set_t cpuset;
          get_random_images_mutex[dev_idx+ i*dev_cnt].lock();
          std::thread t(&Benchmark::get_random_images_worker, this, dev_idx+ i*dev_cnt);
      
          CPU_ZERO(&cpuset);
          CPU_SET(coreid+i%8, &cpuset);
#ifdef R282
         if(dev_idx < 4 || settings->qaic_device_count > 5)
#endif
            pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
          t.detach();
        }
      }
    }
#endif



    acConfig.priorfilename = _settings->nms_priors_bin_path();

    nwOutputLayer = new AnchorBoxProc(acConfig);

    nms_results.resize(settings->qaic_device_count);
    reformatted_results.resize(settings->qaic_device_count);

    for (int dev_idx = 0; dev_idx < settings->qaic_device_count; ++dev_idx) {
      std::thread t(&Benchmark::initResultsBuffer, this, dev_idx);
#if defined(G292) || defined(R282)
      unsigned coreid = (dev_idx > 7) ? -(START_CORE) + dev_idx * 8 : (START_CORE) + dev_idx * 8;
      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(coreid, &cpuset);
#ifdef R282
      if(dev_idx < 4 || settings->qaic_device_count > 5)
#endif
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
    get_next_results_batch_idx.resize(CTN * dev_cnt);
    get_next_results_turn.resize(dev_cnt);
    
#if defined(G292) || defined (R282)
    for (int dev_idx = 0; dev_idx < settings->qaic_device_count; ++dev_idx) {
      get_next_results_turn[dev_idx] = 0;
      for (int i = 0; i < CTN; i++) {
        get_next_results_mutex[dev_idx + i * dev_cnt].lock();
        std::thread t(&Benchmark::get_next_results_worker, this,
                      dev_idx + i * dev_cnt);

        unsigned coreid = (dev_idx > 7) ? -(START_CORE) + dev_idx * 8 : (START_CORE) + dev_idx * 8;
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
#ifdef R282
        CPU_SET(coreid + i%8 + (dev_idx > 3 &&  settings->qaic_device_count > 5)*4 , &cpuset);
#else
        CPU_SET(coreid + i%8, &cpuset);
#endif

#ifdef R282
        if(dev_idx < 4 || settings->qaic_device_count > 5)
#endif
        pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
        t.detach();
      }
    }
#endif

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
#if defined(G292) || defined(R282)
    for (int dev_idx = 0; dev_idx < _settings->qaic_device_count; ++dev_idx) {
      std::thread t(&Benchmark::load_images_locally, this, dev_idx);
      unsigned coreid = AFFINITY_CARD(dev_idx);

      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(coreid, &cpuset);
#ifdef R282
      if(dev_idx < 4 || _settings->qaic_device_count > 5)
#endif
      pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);

      t.join();
    }
#else
    load_images_locally(0);

#endif
  }

  void unload_images(size_t num_examples) override {
    uint16_t batch_size = _settings->qaic_batch_size;
#if defined(G292) || defined(R282)
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
  
#if defined(G292) || defined(R282)
  void get_random_images_worker(int fake_idx) {
    int dev_cnt =  _settings->qaic_device_count;
    int dev_idx = fake_idx;
    while(dev_idx - dev_cnt >= 0)
     dev_idx -= dev_cnt;

    while(true) {
      get_random_images_mutex[fake_idx].lock();
      const std::vector<mlperf::QuerySample> &samples = *get_random_images_samples[fake_idx];
      const int act_idx = get_random_images_act_idx[fake_idx];
      const int set_idx = get_random_images_set_idx[fake_idx];
      for (int i = 0; i < samples.size(); ++i) {
        TInputDataType *ptr =
          ((TInputDataType *)_in_ptrs[dev_idx][act_idx][set_idx]) +
          i * _settings->image_size_width() * _settings->image_size_height() *
              _settings->num_channels();
          _in_converter->convert(
          _in_batch[dev_idx][session->idx2loc[samples[i].index]].get(), ptr);
      }
      get_random_images_finished[fake_idx] = true;
      get_random_images_mutex2[fake_idx].unlock();
    }
  }

  void get_random_images(const std::vector<mlperf::QuerySample> &samples,
                         int dev_idx, int act_idx, int set_idx) override {
    int dev_cnt =  _settings->qaic_device_count;
    const int CTN = _settings->copy_threads_per_device;
    get_random_images_mutex3[dev_idx].lock();
    const int turn = (get_random_images_turn[dev_idx]+1)%CTN;
    const int fake_idx = turn*dev_cnt + dev_idx;
    get_random_images_turn[dev_idx] = turn;
    get_random_images_mutex3[dev_idx].unlock();
    get_random_images_mutex2[fake_idx].lock();
    get_random_images_samples[fake_idx] = &samples;
    get_random_images_act_idx[fake_idx] = act_idx;
    get_random_images_set_idx[fake_idx] = set_idx;

    get_random_images_finished[fake_idx] = false;
    get_random_images_mutex[fake_idx].unlock();
    while(true) {
      if(get_random_images_finished[fake_idx])
        return;
      std::this_thread::sleep_for(std::chrono::nanoseconds(1));
    }
  }
#else
  void get_random_images(const std::vector<mlperf::QuerySample> &samples,
                         int dev_idx, int act_idx, int set_idx) override {
    for (int i = 0; i < samples.size(); ++i) {
      TInputDataType *ptr =
          ((TInputDataType *)_in_ptrs[dev_idx][act_idx][set_idx]) +
          i * _settings->image_size_width() * _settings->image_size_height() *
              _settings->num_channels();
      _in_converter->convert(
          _in_batch[0][session->idx2loc[samples[i].index]].get(), ptr);
    }
  }
#endif

  virtual void *get_img_ptr(int dev_idx, int img_idx) {
#if !defined(G292) && !defined(R282)
    return _in_batch[0][session->idx2loc[img_idx]].get()->data();
#else
    return _in_batch[dev_idx][session->idx2loc[img_idx]].get()->data();
#endif
  }

#if defined(G292) || defined(R282)
  void get_next_results_worker(int fake_idx) {

    int dev_cnt = _settings->qaic_device_count;
    int dev_idx = fake_idx;
    while (dev_idx - dev_cnt >= 0)
      dev_idx -= dev_cnt;
    while (true) {
      get_next_results_mutex[fake_idx].lock();
      int image_idx_in_batch = get_next_results_batch_idx[fake_idx];
      int i = image_idx_in_batch;
      get_next_results_batch_mutex[fake_idx].unlock();
      const std::vector<int> &image_idxs =
          *get_next_results_image_idxs[fake_idx];
      std::vector<ResultData *> &results = *get_next_results_results[fake_idx];

      const int act_idx = get_next_results_act_idx[fake_idx];
      const int set_idx = get_next_results_set_idx[fake_idx];


      TOutput1DataType *boxes_ptr =
          (TOutput1DataType *)_out_ptrs[dev_idx][act_idx][set_idx][BOXES_INDEX];
      TOutput2DataType *classes_ptr = (TOutput2DataType *)
          _out_ptrs[dev_idx][act_idx][set_idx][CLASSES_INDEX];

      nms_results[dev_idx][act_idx][set_idx][i].clear();

      // get pointers to unique buffer for device->activation->set
      std::vector<std::vector<float> > &nms_res =
          nms_results[dev_idx][act_idx][set_idx][i];
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

      results.push_back(next_result_ptr);
      get_next_results_finished[fake_idx]++;
      if(get_next_results_finished[fake_idx] ==  _settings->qaic_batch_size)
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

    get_next_results_finished[fake_idx] = 0;
    results.clear();
    for(int i = 0; i < image_idxs.size(); i++){
      get_next_results_batch_mutex[fake_idx].lock();
      get_next_results_batch_idx[fake_idx] = i;
      get_next_results_mutex[fake_idx].unlock();
    }
    while (true) {
      if (get_next_results_finished[fake_idx] == image_idxs.size())
        return;
      std::this_thread::sleep_for(std::chrono::nanoseconds(1));
    }
  }
#else
  void get_next_results(std::vector<int> &image_idxs,
                        std::vector<ResultData *> &results, int dev_idx,
                        int act_idx, int set_idx) override {

    TOutput1DataType *boxes_ptr =
        (TOutput1DataType *)_out_ptrs[dev_idx][act_idx][set_idx][BOXES_INDEX];
    TOutput2DataType *classes_ptr = (TOutput2DataType *)
        _out_ptrs[dev_idx][act_idx][set_idx][CLASSES_INDEX];

    for(int i = 0; i < image_idxs.size(); i++){
      nms_results[dev_idx][act_idx][set_idx][i].clear();

      // get pointers to unique buffer for device->activation->set
      std::vector<std::vector<float> > &nms_res =
          nms_results[dev_idx][act_idx][set_idx][i];
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

      results.push_back(next_result_ptr);
    }
  }
#endif
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
  std::mutex get_random_images_mutex[256];
  std::mutex get_random_images_mutex2[256];
  std::mutex get_random_images_mutex3[16];
  std::vector<const std::vector<mlperf::QuerySample>*> get_random_images_samples;
  std::vector<int> get_random_images_act_idx;
  std::vector<int> get_random_images_set_idx;
  std::vector<int> get_random_images_finished;
  std::vector<int> get_random_images_turn;

  uint8_t* copy_src[256][8];
  uint8_t* copy_dest[256][8];
  size_t copy_size[256][8];
  bool copy_finished[256][8];
  std::mutex copy_mutex[256][8];


  std::vector<std::vector<std::vector<std::vector<std::vector<std::vector<float> > > > > >
  nms_results;
  std::vector<std::vector<std::vector<std::vector<ResultData *> > > > reformatted_results;

  std::mutex get_next_results_mutex[256];
  std::mutex get_next_results_mutex2[256];
  std::mutex get_next_results_mutex3[16];
  std::mutex get_next_results_batch_mutex[256];

  std::vector<std::vector<int> *> get_next_results_image_idxs;
  std::vector<std::vector<ResultData *> *> get_next_results_results;

  std::vector<int> get_next_results_act_idx;
  std::vector<int> get_next_results_set_idx;
  std::vector<int> get_next_results_finished;
  std::vector<int> get_next_results_batch_idx;
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
  InCopy(BenchmarkSettings *s) {
  }


  void convert(ImageData *source, void *target) {
    size_t size = source -> size();
    uint8_t *src = source -> data();
#if defined(__amd64__) && defined(ENABLE_ZEN2)
#ifndef MODEL_R34
      __m128i *srca =  reinterpret_cast< __m128i*>(src);
      __m128i *desta = reinterpret_cast<__m128i*>(target);
      int64_t vectors = size / sizeof(*srca);
      for (; vectors > 0; vectors--, srca++, desta++) {
        const __m128i loaded = _mm_stream_load_si128(srca);
        _mm_stream_si128(desta, loaded);
      }
#else
      __m256i *srca =  reinterpret_cast< __m256i*>(src);
      __m256i *desta = reinterpret_cast<__m256i*>(target);
      int64_t vectors = size / sizeof(*srca);
      for (; vectors > 0; vectors--, srca++, desta++) {
        const __m256i loaded = _mm256_stream_load_si256(srca);
        _mm256_stream_si256(desta, loaded);
      }
#endif
      unsigned rem = size%sizeof(*srca);
      if(rem > 0) {
        memcpy((uint8_t*)desta, (uint8_t*)srca, rem);
      }
      _mm_sfence();
#else
      memcpy(target, src, size);
#endif
  }
};

//----------------------------------------------------------------------

class OutCopy {
public:
  OutCopy(BenchmarkSettings *s) : _settings(s) {

   /* std::vector<int> exclude{ 12, 26, 29, 30, 45, 66, 68, 69, 71, 83 };

    for (int i = 0; i < 100; ++i)
      if (std::find(exclude.begin(), exclude.end(), i) == exclude.end())
        class_map.push_back(i);*/
  }

  void convert(int img_idx, const float *boxes, const int64_t *classes,
               const float *scores, const int num, ResultData *target,
               int src_width, int src_height,
               std::vector<std::string> model_classes,
               bool correct_background) const {

  }

private:
  BenchmarkSettings *_settings;
  std::vector<int> class_map;
};

} // namespace CK

#endif

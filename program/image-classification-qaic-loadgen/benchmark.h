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

#include "loadgen.h"
#include <assert.h>
#include <dirent.h>
#include <fstream>
#include <iostream>
#include <map>
#include <math.h>
#include <memory>
#include <sstream>
#include <string.h>
#include <thread>
#include <vector>

#if defined(__amd64__) && defined(ENABLE_ZEN2)
#include <immintrin.h>
#include <cstdint>
#endif

#include "QAicInfApi.h"
#include "settings.h"

#define DEBUG(msg) std::cout << "DEBUG: " << msg << std::endl;


namespace CK {

//----------------------------------------------------------------------

class BenchmarkSession {
public:
  BenchmarkSession(const BenchmarkSettings *settings) : _settings(settings) {}

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
        _filenames_buffer.emplace_back(list_of_available_imagefiles[idx]);
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
  const BenchmarkSettings *_settings;
  std::vector<std::string> _filenames_buffer;
};

//----------------------------------------------------------------------

template <typename TData> class StaticBuffer {
public:
  StaticBuffer(int size, const std::string &dir, TData *ptr = NULL)
      : _size(size), _dir(dir) {
    if (!ptr)
      _buffer = (TData*)aligned_alloc(32, size);
    else
      _buffer = ptr;
  }

  virtual ~StaticBuffer() { free(_buffer); }

  TData *data() const { return _buffer; }
  int size() const { return _size; }

protected:
  const int _size;
  const std::string _dir;
  TData *_buffer;
};

class ImageData : public StaticBuffer<uint8_t> {
public:
  ImageData(const BenchmarkSettings *s, uint8_t *buf = NULL)
      : StaticBuffer(s->image_size * s->image_size * s->num_channels *
                         ((s->qaic_skip_stage != "convert") ? sizeof(float)
                                                            : sizeof(uint8_t)),
                     s->images_dir, buf) {}

  virtual void load(const std::string &filename, int vl) {
    auto path = _dir + '/' + filename;
    std::ifstream file(path, std::ios::in | std::ios::binary);
    if (!file)
      throw "Failed to open image data " + path;
    file.read(reinterpret_cast<char *>(_buffer), _size);
    if (vl > 1) {
      std::cout << "Loaded file: " << path << std::endl;
    } else if (vl) {
      std::cout << 'l' << std::flush;
    }
  }
};

//----------------------------------------------------------------------

template <typename TData> class ImageDataFormat : public ImageData {
public:
  ImageDataFormat(const BenchmarkSettings *s, uint8_t *buf = NULL)
      : ImageData(s, buf) {}

  virtual void load(const std::string &filename, int vl, bool isNHWC) {
    auto path = _dir + '/' + filename;
    std::ifstream file(path, std::ios::in | std::ios::binary);
    if (!file)
      throw "Failed to open image data " + path;
    TData *tmp = new TData[_size / sizeof(TData)];
    file.read(reinterpret_cast<char *>(tmp), _size);
    if (vl > 1) {
      std::cout << "Loaded file: " << path << std::endl;
    } else if (vl) {
      std::cout << 'l' << std::flush;
    }
    convert((TData *)tmp, (TData *)_buffer, _size / sizeof(TData), isNHWC);
    delete[] tmp;
  }

  void convert(const TData *source, TData *target, int size, bool isNHWC) {
    if (isNHWC) {
      std::copy(source, source + size, target);
      return;
    }
    for (int i = 0; i < size; i++) {
      TData px = source[i];
      int offset = i % 3 * size / 3;
      target[i / 3 + offset] = px;
    }
  }
};

//----------------------------------------------------------------------

class ResultData : public StaticBuffer<float> {
public:
  ResultData(const BenchmarkSettings *s)
      : StaticBuffer<float>(s->num_classes, s->result_dir) {}

  void save(const std::string &filename) {
    auto path = _dir + '/' + filename + ".txt";
    std::ofstream file(path);
    if (!file)
      throw "Unable to create result file " + path;
    for (int i = 0; i < _size; i++)
      file << _buffer[i] << std::endl;
  }

  int argmax() {
    int arg_index = 0;
    float max_value = _buffer[0];

    for (int i = 1; i < _size; i++) {
      if (_buffer[i] > max_value) {
        arg_index = i;
        max_value = _buffer[i];
      }
    }

    return arg_index;
  }
};

//----------------------------------------------------------------------

class IBenchmark {
public:
  virtual ~IBenchmark() {}
  virtual void load_images(BenchmarkSession *session) = 0;
  virtual void unload_images(size_t num_examples) = 0;
  virtual void save_results() = 0;

  virtual void get_next_results(int num_results, std::vector<int> &results,
                                int dev_idx, int act_idx, int set_idx) = 0;
  virtual void
  get_random_images(const std::vector<mlperf::QuerySample> &samples,
                    int dev_idx, int act_idx, int set_idx) = 0;

  virtual void *get_img_ptr(unsigned dev_idx, int img_idx) = 0;
};

template <typename TInConverter, typename TOutConverter,
          typename TInputDataType>
class Benchmark : public IBenchmark {
public:
  Benchmark(
      const BenchmarkSettings *settings,
      std::vector<std::vector<std::vector<void *>>> &in_ptrs,
      std::vector<std::vector<std::vector<std::vector<void *>>>> &out_ptrs)
      : _settings(settings) {
    _in_ptrs = in_ptrs;
    _out_ptrs = out_ptrs;
    _in_converter.reset(new TInConverter(settings));
    _out_converter.reset(new TOutConverter(settings));
    int dev_cnt =  settings->qaic_device_count; 
    _in_batch.resize(dev_cnt);
    _out_batch.resize(dev_cnt);
#ifdef G292
    const int CTN = settings -> copy_threads_per_device;
    get_random_images_samples.resize(CTN*dev_cnt);
    get_random_images_act_idx.resize(CTN*dev_cnt);
    get_random_images_set_idx.resize(CTN*dev_cnt);
    get_random_images_finished.resize(CTN*dev_cnt);
    get_random_images_turn.resize(dev_cnt);
    for (int dev_idx = 0; dev_idx < dev_cnt; ++dev_idx) {
      get_random_images_turn[dev_idx]=0;
      unsigned coreid = (dev_idx > 7)? -64 + dev_idx*8: 64 + dev_idx*8;
      for (int i = 0; i < CTN; i++) {
        cpu_set_t cpuset;
        std::thread t(&Benchmark::get_random_images_worker, this, dev_idx+ i*dev_cnt);
        get_random_images_mutex[dev_idx+ i*dev_cnt].lock();
      
        CPU_ZERO(&cpuset);
        CPU_SET(coreid+i, &cpuset);
        pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
        t.detach();
      }
    }
#endif
  }
  void load_images_locally(BenchmarkSession *_session, int d) { 
    auto vl = _settings->verbosity_level;

    const std::vector<std::string> &image_filenames =
        session->current_filenames();

    unsigned length = image_filenames.size();
    _current_buffer_size = length;
    _in_batch[d] = new std::unique_ptr<ImageDataFormat<TInputDataType>>[length];
    _out_batch[d] = new std::unique_ptr<ResultData>[length];
    unsigned batch_size = _settings->qaic_batch_size;
    unsigned image_size = _settings->image_size * _settings->image_size *
                          _settings->num_channels * sizeof(TInputDataType);
    for (auto i = 0; i < length; i += batch_size) {
      unsigned actual_batch_size =
          std::min(batch_size, batch_size < length ? (length - i) : length);
      uint8_t *buf = (uint8_t*)aligned_alloc(32, batch_size * image_size);
      for (auto j = 0; j < actual_batch_size; j++, buf += image_size) {
        _in_batch[d][i + j].reset(
            new ImageDataFormat<TInputDataType>(_settings, buf));
        _out_batch[d][i + j].reset(new ResultData(_settings));
        _in_batch[d][i + j]->load(image_filenames[i + j], vl, _settings->isNHWC);
      }
    }
  }
 
  void load_images(BenchmarkSession *_session) override {
    session = _session;
#ifdef G292
    int i = 64;
    for (int dev_idx = 0; dev_idx < _settings->qaic_device_count; ++dev_idx) {
      std::thread t(&Benchmark::load_images_locally, this, _session, dev_idx);

      cpu_set_t cpuset;
      CPU_ZERO(&cpuset);
      CPU_SET(i+dev_idx*8, &cpuset);
      // CPU_SET(i+dev_idx*8+4, &cpuset);
      if(dev_idx == 7) i = -64;
      pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);

      t.join();
    }
#else
    load_images_locally( _session, 0);

#endif

  }

  void unload_images(size_t num_examples) override {
    uint16_t batch_size = _settings->qaic_batch_size;
#ifdef G292
    int N =  _settings->qaic_device_count;
#else
    int N = 1;
#endif
    for (size_t i = 0; i < num_examples; i += batch_size) {
      for (int dev_idx = 0; dev_idx < N; ++dev_idx) {
        delete _in_batch[dev_idx][i].get();
        delete _out_batch[dev_idx][i].get();
      }
    }
  }

#ifdef G292
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
          i * _settings->image_size * _settings->image_size *
              _settings->num_channels;
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
    const int CTN =  _settings->copy_threads_per_device;
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
          i * _settings->image_size * _settings->image_size *
              _settings->num_channels;
      _in_converter->convert(
          _in_batch[0][session->idx2loc[samples[i].index]].get(), ptr);
    }
  }
#endif

  virtual void *get_img_ptr(unsigned dev_idx, int img_idx) {
    return _in_batch[dev_idx][session->idx2loc[img_idx]].get()->data();
  }

  void get_next_results(int num_results, std::vector<int> &results, int dev_idx,
                        int act_idx, int set_idx) override {
    results.clear();
    int probe_offset = _settings->has_background_class ? 1 : 0;
    for (int i = 0; i < num_results; ++i) {

      int64_t *ptr = (int64_t *)_out_ptrs[dev_idx][act_idx][set_idx][0] + i;
      _out_buffer_index %= _current_buffer_size;
      results.push_back((int)*ptr - probe_offset);
    }
  }

  void save_results() override {
    const std::vector<std::string> &image_filenames =
        session->current_filenames();
    int i = 0;
     for (auto image_file : image_filenames) {
       (*_out_batch[i++])->save(image_file);
     }
  }

private:
  const BenchmarkSettings *_settings;
  BenchmarkSession *session;
  int _out_buffer_index = 0;
  int _current_buffer_size = 0;
  std::vector<std::vector<std::vector<void *>>> _in_ptrs;
  std::vector<std::vector<std::vector<std::vector<void *>>>> _out_ptrs;
  std::vector<std::unique_ptr<ImageDataFormat<TInputDataType>>*> _in_batch;
  std::vector<std::unique_ptr<ResultData>*> _out_batch;
  std::unique_ptr<TInConverter> _in_converter;
  std::unique_ptr<TOutConverter> _out_converter;
  std::mutex get_random_images_mutex[256];
  std::mutex get_random_images_mutex2[256];
  std::mutex get_random_images_mutex3[16];
  std::vector<const std::vector<mlperf::QuerySample>*> get_random_images_samples;
  std::vector<int> get_random_images_act_idx;
  std::vector<int> get_random_images_set_idx;
  std::vector<int> get_random_images_finished;
  std::vector<int> get_random_images_turn;

};

//----------------------------------------------------------------------

class IinputConverter {
public:
  virtual ~IinputConverter() {}
  virtual void convert(const ImageData *source, void *target) = 0;
};

//----------------------------------------------------------------------

class InCopy : public IinputConverter {
public:
  InCopy(const BenchmarkSettings *s) {}

  inline void convert(const ImageData *source, void *target) {
#if defined(__amd64__) && defined(ENABLE_ZEN2)
    const __m256i *src =  reinterpret_cast<const __m256i*>(source->data());
    __m256i *dest = reinterpret_cast<__m256i*>(target);
    int64_t vectors = source->size() / sizeof(*src);
    for (; vectors > 0; vectors--, src++, dest++) {
      const __m256i loaded = _mm256_stream_load_si256(src);
      _mm256_stream_si256(dest, loaded);
    }
    _mm_sfence();
#else
    uint8_t *uint8_target = static_cast<uint8_t *>(target);
    std::copy(source->data(), source->data() + source->size(), uint8_target);
#endif
  }
};

//----------------------------------------------------------------------

class InNormalize : public IinputConverter {
public:
  InNormalize(const BenchmarkSettings *s)
      : _normalize_img(s->normalize_img), _subtract_mean(s->subtract_mean),
        _given_channel_means(s->given_channel_means),
        _num_channels(s->num_channels) {}

  void convert(const ImageData *source, void *target) {
    // Copy image data to target
    float *float_target = static_cast<float *>(target);
    float sum = 0;
    for (int i = 0; i < source->size(); i++) {
      float px = source->data()[i];
      if (_normalize_img)
        px = (px / 255.0 - 0.5) * 2.0;
      sum += px;
      float_target[i] = px;
    }
    // Subtract mean value if required
    if (_subtract_mean) {
      if (_given_channel_means) {
        for (int i = 0; i < source->size(); i++)
          float_target[i] -=
              _given_channel_means[i % _num_channels]; // assuming NHWC order!
      } else {
        float mean = sum / static_cast<float>(source->size());
        for (int i = 0; i < source->size(); i++)
          float_target[i] -= mean;
      }
    }
  }

private:
  const bool _normalize_img;
  const bool _subtract_mean;
  const float *_given_channel_means;
  const int _num_channels;
};

//----------------------------------------------------------------------

class InChannelReorder : public IinputConverter {
public:
  InChannelReorder(const BenchmarkSettings *s) {}

  void convert(const ImageData *source, void *target) {

    float *float_target = static_cast<float *>(target);
    int size = source->size() / 4;

    for (int i = 0; i < size; i++) {
      float px = ((float *)source->data())[i];
      int offset = i % 3 * size / 3;
      float_target[i / 3 + offset] = px;
    }
  }
};

//----------------------------------------------------------------------

class OutCopy {
public:
  OutCopy(const BenchmarkSettings *s) {}

  void convert(const float *source, ResultData *target) const {
    std::copy(source, source + target->size(), target->data());
  }
};

//----------------------------------------------------------------------

class OutDequantize {
public:
  OutDequantize(const BenchmarkSettings *s) {}

  void convert(const uint8_t *source, ResultData *target) const {
    for (int i = 0; i < target->size(); i++)
      target->data()[i] = source[i] / 255.0;
  }
};

} // namespace CK

#endif

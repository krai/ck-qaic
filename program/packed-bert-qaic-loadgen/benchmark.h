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
#include "affinity.h"

#include "query_sample_library.h"

typedef std::pair<mlperf::QuerySample,int> SizedSample;

namespace CK {

//----------------------------------------------------------------------

class BenchmarkSession {
public:
  BenchmarkSession(const BenchmarkSettings *settings) : _settings(settings) {}

  virtual ~BenchmarkSession() {}

  const std::vector<std::string> &
  load_filenames(std::vector<size_t> img_indices) {

    // nothing to do here as we're loading the entire files as input
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

class InputData {

public:
  int *data() const { return nullptr; }
  int size() const { return 0; }
};


//----------------------------------------------------------------------

class ResultData : public StaticBuffer<float> {
public:
  ResultData(const BenchmarkSettings *s)
      : StaticBuffer<float>(0xdeadbeef, s->result_dir) {}

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
  virtual void load_inputs(std::vector<size_t> img_indices) = 0;
  virtual void unload_inputs(size_t num_examples) = 0;
  virtual void save_results() = 0;

  virtual void get_next_results(const std::vector<SizedSample> &samples, std::vector<std::vector<float>> &results,
                                int dev_idx, int act_idx, int set_idx) = 0;
  virtual void
  get_random_inputs(const std::vector<SizedSample> &samples,
                    int dev_idx, int act_idx, int set_idx, int buf_idx) = 0;

  virtual void *get_input_ptr(int input_idx, int buf_idx) = 0;

  virtual int get_sequence_length(int index) = 0;
};

template <typename TInConverter, typename TOutConverter,
          typename TInputDataType, typename TOutputDataType>
class Benchmark : public IBenchmark {
public:
  Benchmark(
      const BenchmarkSettings *settings,
      std::vector<std::vector<std::vector<std::vector<void *>>>> &in_ptrs,
      std::vector<std::vector<std::vector<std::vector<void *>>>> &out_ptrs)
      : _settings(settings) {
    _in_ptrs = in_ptrs;
    _out_ptrs = out_ptrs;
    _in_converter.reset(new TInConverter(settings));
    _out_converter.reset(new TOutConverter(settings));


    // load the input_ids
    {
      std::ifstream file(_settings->input_ids, std::ios::in | std::ios::binary);
      if (!file)
          throw "Failed to open input_ids file " + _settings->input_ids;

      file.seekg (0, std::ios::end);
      int size = file.tellg();
      file.seekg (0, std::ios::beg);
      _input_ids.resize(size / (sizeof(uint64_t)));
      file.read(reinterpret_cast<char *>(&_input_ids[0]), size);
      file.close();
    }

    // load the input_masks
    {
      std::ifstream file(_settings->input_mask, std::ios::in | std::ios::binary);
      if (!file)
          throw "Failed to open input_mask file " + _settings->input_mask;

      file.seekg (0, std::ios::end);
      int size = file.tellg();
      file.seekg (0, std::ios::beg);
      _input_mask.resize(size / (sizeof(uint64_t)));
      file.read(reinterpret_cast<char *>(&_input_mask[0]), size);
      file.close();
    }


    // load the segment_ids
    {
      std::ifstream file(_settings->segment_ids, std::ios::in | std::ios::binary);
      if (!file)
          throw "Failed to open segment_ids file " + _settings->segment_ids;

      file.seekg (0, std::ios::end);
      int size = file.tellg();
      file.seekg (0, std::ios::beg);
      _segment_ids.resize(size / (sizeof(uint64_t)));
      file.read(reinterpret_cast<char *>(&_segment_ids[0]), size);
      file.close();
    }
  }

  virtual int get_sequence_length(int index) {

    int seq_len = 0;

    for(int i=0 ; i<_settings->max_seq_length ; ++i)
      seq_len += _input_mask[index*_settings->max_seq_length+i];

    return seq_len;
  }

  void load_inputs(std::vector<size_t> img_indices) override {

  // not required

  }

  void unload_inputs(size_t num_examples) override {

  // not required
  }


  void get_random_inputs(const std::vector<SizedSample> &samples,
                         int dev_idx, int act_idx, int set_idx, int buf_idx) override {

    TInputDataType *ptr =
        ((TInputDataType *)_in_ptrs[dev_idx][act_idx][set_idx][buf_idx]);

    if(buf_idx == 1) {
      memset((uint8_t *)ptr, 0, 8 * sizeof(TInputDataType));
      for (int i = 0; i < samples.size(); ++i) {
        ((TInputDataType *)ptr)[i] = samples[i].second;
      }
    } else if(buf_idx == 3) {
      int offset = 0;
      memset(ptr, 0, _settings->max_seq_length*sizeof(TInputDataType));
      for (int i = 0; i < samples.size(); ++i) {
        int seq_len = samples[i].second;
        for(int w=0 ; w<seq_len ; ++w)
          ptr[w+offset]=w;
        offset += seq_len;
      }
    } else {
      int offset = 0;
      memset(ptr, 0, _settings->max_seq_length*sizeof(TInputDataType));
      for (int i = 0; i < samples.size(); ++i) {
        int seq_len = samples[i].second;
	for(int m = 0; m < seq_len; m++) {
          ptr[offset + m] =
              (TInputDataType) *
              ((uint64_t *)get_input_ptr(samples[i].first.index, buf_idx) + m);
        }
   //     memcpy(ptr+offset, get_input_ptr(samples[i].first.index, buf_idx), seq_len*sizeof(TInputDataType));
        offset += seq_len;
      }
    }
  }

  virtual void *get_input_ptr(int input_idx, int buf_idx) {

    if( buf_idx == 0 )
      return &_input_ids[input_idx*_settings->max_seq_length];
    if( buf_idx == 1 )
      return &_input_mask[input_idx*_settings->max_seq_length];
    if( buf_idx == 2 )
      return &_segment_ids[input_idx*_settings->max_seq_length];
    else
      throw "Invalid input pointer index.";
  }

  void get_next_results(const std::vector<SizedSample> &samples, std::vector<std::vector<float>> &results, int dev_idx,
                        int act_idx, int set_idx) override {

    int offset = 0;
    for (int i = 0; i < samples.size(); ++i) {
      int seq_len = samples[i].second;
      results[i].resize(_settings->max_seq_length*2,-10000.0f);
      TOutputDataType *b0 =
          ((TOutputDataType *)_out_ptrs[dev_idx][act_idx][set_idx][0]) + offset;
      TOutputDataType *b1 =
          ((TOutputDataType *)_out_ptrs[dev_idx][act_idx][set_idx][1]) + offset;
      for(int j=0 ; j<seq_len ; ++j) {
        results[i][j*2] =     *(b0 + j);
        results[i][(j*2)+1] = *(b1 + j);
      }
      offset += seq_len;
    }

  }

  void save_results() override {
    const std::vector<std::string> &input_filenames =
        session->current_filenames();
    int i = 0;
    for (auto input_file : input_filenames) {
      _out_batch[i++]->save(input_file);
    }
  }

private:
  const BenchmarkSettings *_settings;
  BenchmarkSession *session;
  int _out_buffer_index = 0;
  int _current_buffer_size = 0;
  std::vector<std::vector<std::vector<std::vector<void *>>>> _in_ptrs;
  std::vector<std::vector<std::vector<std::vector<void *>>>> _out_ptrs;
  std::unique_ptr<ResultData> *_out_batch;
  std::unique_ptr<TInConverter> _in_converter;
  std::unique_ptr<TOutConverter> _out_converter;

  std::vector<int64_t> _input_ids;
  std::vector<int64_t> _input_mask;
  std::vector<int64_t> _segment_ids;
};

//----------------------------------------------------------------------

class IinputConverter {
public:
  virtual ~IinputConverter() {}
  virtual void convert(const InputData *source, void *target) = 0;
};

//----------------------------------------------------------------------

class InCopy : public IinputConverter {
public:
  InCopy(const BenchmarkSettings *s) {}

  inline void convert(const InputData *source, void *target) {
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

class OutCopy {
public:
  OutCopy(const BenchmarkSettings *s) {}

  void convert(const float *source, ResultData *target) const {
    std::copy(source, source + target->size(), target->data());
  }
};


} // namespace CK

#endif

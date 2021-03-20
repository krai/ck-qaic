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

#ifndef HARNESS_H
#define HARNESS_H

#include <algorithm>
#include <future>
#include <numeric>
#include <queue>

#include "loadgen.h"
#include "query_sample_library.h"
#include "system_under_test.h"
#include "test_settings.h"

#include "QAicInfApi.h"
#include "benchmark.h"

using namespace std;
using namespace CK;
using namespace qaic_api;

struct Payload {
  std::vector<mlperf::QuerySample> samples;
  int device;
  int activation;
  int set;
};

class SystemUnderTestQAIC;


class RingBuffer {

public:
  RingBuffer(int d, int a, int s)  {
    size = s;
    for (int i = 0; i < s; ++i) {
      auto p = new Payload;
      p->set = i;
      p->activation = a;
      p->device = d;
      q.push(p);
    }
  }

  virtual ~RingBuffer() { 
    while(!q.empty()){
      auto f = q.front();
      q.pop();
      delete f;
    } 
  }

  Payload *getPayload() {
     std::unique_lock<std::mutex> lock(mtx);
     if(q.empty())
       return nullptr;
     else {
       auto f = q.front();
       q.pop();
       return f;
     }
  }

  void release(Payload *p) {
    std::unique_lock<std::mutex> lock(mtx);
    // std::cout << "Release before: " << front << " end: " << end << std::endl;
    if(q.size() == size ||
      p == nullptr){
      std::cerr << "extra elem in the queue" << std::endl;
      //assert(1);
    }
    q.push(p);
    // std::cout << "Release after: " << front << " end: " << end << std::endl;
  }

  void debug() {
    //std::cout << "QUEUE front: " << front << " end: " << end << std::endl;
  }

private:
  std::queue<Payload *>q;
  int size;
  bool isEmpty;
  std::mutex mtx;
};


class Program {
public:
  Program();

  virtual ~Program();

  void LoadNextBatch(const std::vector<mlperf::QuerySampleIndex> &img_indices);

  void ColdRun();

  void Inference(std::vector<mlperf::QuerySample> samples);

  static void QueueScheduler();

  static void PostResults(QAicEvent *event,
                          QAicEventCompletionType eventCompletion,
                          void *userData);

  void UnloadBatch(const std::vector<mlperf::QuerySampleIndex> &img_indices);

  const int available_images_max();

  const int images_in_memory_max();

  static void setSUT(SystemUnderTestQAIC *s);

  static BenchmarkSettings *settings;

private:
  static BenchmarkSession *session;
  static std::vector<QAicInfApi*> runners;
  static unique_ptr<IBenchmark> benchmark;
  static SystemUnderTestQAIC *sut;
  static std::vector<std::vector<mlperf::QuerySample>> samples_queue;
  static int samples_queue_len;
  static std::vector<RingBuffer *> ring_buf;

  static std::atomic<int> sfront, sback;

  static std::mutex mtx_queue;
  static std::mutex mtx_response;
  static std::mutex mtx_ringbuf;

  static bool terminate;

  std::thread scheduler;
};

class SystemUnderTestQAIC : public mlperf::SystemUnderTest {
public:
  SystemUnderTestQAIC(Program *_prg, mlperf::TestScenario _scenario);

  ~SystemUnderTestQAIC() override;

  const std::string &Name() const override { return name_; }

  void ServerModeScheduler();

  void IssueQuery(const std::vector<mlperf::QuerySample> &samples) override;

  void QueryResponse(std::vector<mlperf::QuerySample> &samples,
                     std::vector<ResultData *> results);

  void FlushQueries() override;

  void ReportLatencyResults(
      const std::vector<mlperf::QuerySampleLatency> &latencies_ns) override;

private:
  std::string name_{"QAIC_SUT"};
  Program *prg;
  long query_counter;
  mlperf::TestScenario scenario;

  std::vector<mlperf::QuerySample> samples_queue;
  std::mutex mtx_samples_queue;
  std::chrono::time_point<std::chrono::steady_clock> prev;

  bool terminate;
  std::thread scheduler;
};

#endif //HARNESS_H

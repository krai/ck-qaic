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

#include <algorithm>
#include <future>
#include <numeric>
#include <chrono>

#include "loadgen.h"
#include "query_sample_library.h"
#include "system_under_test.h"
#include "test_settings.h"

#include "benchmark.h"
#include "harness.h"

#include "QAicInfApi.h"

#include "pack.h"

using namespace qaic_api;

using namespace std;
using namespace CK;

Program::Program() {

  settings = new BenchmarkSettings();

  for (int d = 0; d < settings->qaic_device_count; ++d) {

    std::cout << "Creating device " << d << std::endl;
    runners.push_back(new QAicInfApi());

    runners[d]->setModelBasePath(settings->qaic_model_root);
    runners[d]->setNumActivations(settings->qaic_activation_count);
    runners[d]->setSetSize(settings->qaic_set_size);
    runners[d]->setNumThreadsPerQueue(settings->qaic_threads_per_queue);
    runners[d]->setSkipStage(settings->qaic_skip_stage);
    QStatus status = runners[d]->init(settings->qaic_hw_ids[d], PostResults);

    if (status != QS_SUCCESS)
      throw "Failed to invoke qaic";
  }

  // device, activation, set, buffer no
  std::vector<std::vector<std::vector<std::vector<void *>>>> in(settings->qaic_device_count);
  std::vector<std::vector<std::vector<std::vector<void *>>>> out(settings->qaic_device_count);

  // get references to all the buffers devices->activations->set
  for (int d = 0; d < settings->qaic_device_count; ++d) {
    in[d].resize(settings->qaic_activation_count);
    out[d].resize(settings->qaic_activation_count);
    for (int a = 0; a < settings->qaic_activation_count; ++a) {
      in[d][a].resize(settings->qaic_set_size);
      out[d][a].resize(settings->qaic_set_size);
      for (int s = 0; s < settings->qaic_set_size; ++s) {
        for (int i = 0; i < settings->input_count; ++i) {
          in[d][a][s].push_back((void *)runners[d]->getBufferPtr(a, s, i));
        }
        for (int o = 0; o < settings->output_count; ++o) {
          out[d][a][s].push_back((void *)runners[d]->getBufferPtr(a, s, o + settings->input_count));
        }
      }
    }
  }
  if (settings->qaic_skip_stage != "convert")
    benchmark.reset(new Benchmark<InCopy, OutCopy, uint64_t>(settings, in, out));
  else
    benchmark.reset(new Benchmark<InCopy, OutCopy, uint32_t>(settings, in, out));

  // create enough ring buffers for each activation within all devices
  ring_buf.resize(settings->qaic_activation_count *
                  settings->qaic_device_count);

  // fill ring buffer with d0a0, d1a0, ... dna0, d0a1, d1a1, ... dnan
  for (int a = 0; a < settings->qaic_activation_count; ++a)
    for (int d = 0; d < settings->qaic_device_count; ++d)
      ring_buf[d + a * settings->qaic_device_count] =
          new RingBuffer(d, a, settings->qaic_set_size);

  samples_queue.resize(samples_queue_len);
  sfront = sback = 0;

  // Kick off the scheduler
  scheduler = std::thread(QueueScheduler);

#ifdef __amd64__
  num_setup_threads = 8;
#else
  num_setup_threads = 2;
#endif

  //payloads = new Payload[num_setup_threads];
  for(int i=0 ; i<num_setup_threads ; ++i) {
    std::thread t(&Program::EnqueueShim, this, i);

#ifdef __amd64__
    // Create a cpu_set_t object representing a set of CPUs. Clear it and mark
    // only CPU i as set.
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(i*4, &cpuset);
    pthread_setaffinity_np(t.native_handle(), sizeof(cpu_set_t), &cpuset);
#endif

    t.detach();
  }

  std::cout << "Benchmark initialized successfully." << std::endl;
}

Program::~Program() {
  terminate = true;
  scheduler.join();
  std::this_thread::sleep_for(std::chrono::milliseconds(1000));
}

void Program::LoadNextBatch(
    const std::vector<mlperf::QuerySampleIndex> &img_indices) {
  auto vl = settings->verbosity_level;

  if (vl > 1) {
    cout << "LoadNextBatch([";
    for (auto idx : img_indices) {
      cout << idx << ' ';
    }
    cout << "])" << endl;
  } else if (vl) {
    cout << 'B' << flush;
  }
  //session->load_filenames(img_indices);
  benchmark->load_inputs(img_indices);

  if (vl) {
    cout << endl;
  }
}

void Program::ColdRun() {
  auto vl = settings->verbosity_level;

  if (vl > 1) {
    cout << "Triggering a Cold Run..." << endl;
  } else if (vl) {
    cout << 'C' << flush;
  }

  // QStatus status = runner->run(totalSetsCompleted, totalInferencesCompleted);
  // if (status != QS_SUCCESS)
  //  throw "Failed to invoke qaic";
}

void Program::Inference(std::vector<mlperf::QuerySample> samples) {

  std::vector<SizedSample> sized_samples;

  for(int i=0 ; i<samples.size() ; ++i) {
      sized_samples.push_back(SizedSample(samples[i], benchmark->get_sequence_length(samples[i].index)));
  }

  std::vector<std::vector<SizedSample>> packed_samples;

  pack(sized_samples, settings->max_seq_length, 3, packed_samples);

  for(int x=0 ; x<packed_samples.size() ; ++x) {

    while (sback >= sfront + samples_queue_len)
      std::this_thread::sleep_for(std::chrono::microseconds(1));

    samples_queue[sback % samples_queue_len] = packed_samples[x];
    ++sback;
  }

}

void Program::EnqueueShim(int id) {
  while(!terminate) {
    if(payloads[id] != nullptr) {
      Payload* p = Program::payloads[id];

    //std::this_thread::sleep_for(std::chrono::microseconds(1000));
      // set the inputs
      if (settings->input_select == 0) {
        for(int i=0 ; i<settings->input_count ; ++i) {
          benchmark->get_random_inputs(p->samples, p->device, p->activation,
                                       p->set, i);
        }
      } else {
        // Do nothing - random data
      }

      //std::cout << "PUSHING TO HARDWARE - " << p->samples.size() << endl;
      QStatus status = runners[p->device]->run(p->activation, p->set, p);
      if (status != QS_SUCCESS)
        throw "Failed to invoke qaic";

      //PostResults(NULL,
      //            QAIC_EVENT_DEVICE_COMPLETE,
      //            p);

      Program::payloads[id] = nullptr;
    }
    std::this_thread::sleep_for(std::chrono::nanoseconds(10));
  }
}

void Program::QueueScheduler() {

  // total number of activations over all devices
  int activation_count =
      settings->qaic_device_count * settings->qaic_activation_count;

  // current activation index
  int activation = -1;

  int round_robin = 0;

  std::vector<SizedSample> qs;

  while (!terminate) { // loop forever waiting for inputs

    mtx_queue.lock();
    if (sfront == sback) {
      // No samples then continue
      mtx_queue.unlock();
      std::this_thread::sleep_for(std::chrono::nanoseconds(10));
      continue;
    }

    // copy the input list and remove from queue
    qs = samples_queue[sfront % samples_queue_len];
    ++sfront;

    if(settings->verbosity_server)
      std::cout << "<" << sback - sfront << ">";
    mtx_queue.unlock();
    unsigned round = 0;

    while (!terminate) {
            if(activation + 1 == activation_count) round = (round +1)%(num_setup_threads/activation_count);
      activation = (activation + 1) % activation_count;

      Payload *p = ring_buf[activation]->getPayload();

      std::this_thread::sleep_for(std::chrono::microseconds(1));

      // if no hardware slots available then increment the activation
      // count and then continue
      if (p == nullptr) {
        continue;
      }

      // add the input samples to the payload
      p->samples = qs;

      while(Program::payloads[round*activation_count +activation] != nullptr){
        std::this_thread::sleep_for(std::chrono::nanoseconds(10));
      }

      Program::payloads[round*activation_count +activation] = p;

      //std::cout << " " << round_robin;
      //round_robin = (round_robin+1)%num_setup_threads;

      break;
    }
  }
}

void Program::PostResults(QAicEvent *event,
                          QAicEventCompletionType eventCompletion,
                          void *userData) {

  if (eventCompletion == QAIC_EVENT_DEVICE_COMPLETE) {

    Payload *p = (Payload *)userData;

    std::vector<std::vector<float>> results;
    results.resize(p->samples.size());

    benchmark->get_next_results(p->samples, results, p->device,
                                p->activation, p->set);

    sut->QueryResponse(p->samples, results);

    int activation = p->device + p->activation * settings->qaic_device_count;

    ring_buf[activation]->release(p);
  }
}

void Program::UnloadBatch(
    const std::vector<mlperf::QuerySampleIndex> &img_indices) {
  auto b_size = img_indices.size();

  auto vl = settings->verbosity_level;

  if (vl > 1) {
    cout << "Unloading a batch[" << b_size << "]" << endl;
  } else if (vl) {
    cout << 'U' << flush;
  }

  benchmark->unload_inputs(b_size);
}

const int Program::available_inputs_max() {
  return settings->get_input_count();
}

const int Program::inputs_in_memory_max() {
  return settings->inputs_in_memory_max;
}

void Program::setSUT(SystemUnderTestQAIC *s) { sut = s; }

SystemUnderTestQAIC *Program::sut = nullptr;
BenchmarkSettings *Program::settings = nullptr;

std::vector<QAicInfApi *> Program::runners;

std::vector<RingBuffer *> Program::ring_buf;

std::mutex Program::mtx_queue;
std::vector<std::vector<SizedSample>> Program::samples_queue;
int Program::samples_queue_len = 4096;

unique_ptr<IBenchmark> Program::benchmark;

bool Program::terminate = false;

std::atomic<int> Program::sfront;
std::atomic<int> Program::sback;

std::atomic<Payload *> Program::payloads[256] = { nullptr };

int Program::num_setup_threads = 0;

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

SystemUnderTestQAIC::SystemUnderTestQAIC(Program *_prg,
                                         mlperf::TestScenario _scenario)
    : mlperf::SystemUnderTest() {
  prg = _prg;
  query_counter = 0;
  prg->setSUT(this);
  scenario = _scenario;

  // kick of worker thread in server mode to coalesce
  // multiple samples into the one batch
  if (scenario == mlperf::TestScenario::Server) {
    terminate = false;
    scheduler = std::thread(&SystemUnderTestQAIC::ServerModeScheduler, this);
  }
};

SystemUnderTestQAIC::~SystemUnderTestQAIC() {
  if (scenario == mlperf::TestScenario::Server) {
    terminate = true;
    scheduler.join();
  }
}

void SystemUnderTestQAIC::ServerModeScheduler() {

  prev = std::chrono::steady_clock::now();
  std::chrono::microseconds max_wait = std::chrono::microseconds(prg->settings->max_wait);

  while(!terminate) {
    auto now = std::chrono::steady_clock::now();

    mtx_samples_queue.lock();
    int qlen = samples_queue.size();

    if( qlen != 0  && (now - prev) > max_wait) {
      if(prg->settings->verbosity_server)
        std::cout << "(" << qlen <<  ")";
      prg->Inference(samples_queue);
      samples_queue.clear();
      prev = now;
    }
    mtx_samples_queue.unlock();
    std::this_thread::sleep_for(std::chrono::microseconds(1));
  }
}

void SystemUnderTestQAIC::IssueQuery(
    const std::vector<mlperf::QuerySample> &samples) {

    if (scenario == mlperf::TestScenario::SingleStream ||
        scenario == mlperf::TestScenario::MultiStream ||
        scenario == mlperf::TestScenario::Offline) {

    ++query_counter;
    auto vl = prg->settings->verbosity_level;
    if (vl > 1) {
      cout << query_counter << ") IssueQuery([" << samples.size() << "],"
           << samples[0].id << "," << samples[0].index << ")" << endl;
    } else if (vl) {
      cout << 'Q' << flush;
    }

    int num_samples = samples.size();

    int batch_size = prg->settings->qaic_batch_size;

    for (int j = 0; j < num_samples; j += batch_size) {

      std::vector<mlperf::QuerySample> batch_samples;

      int batch_sample_count =
          j + batch_size < num_samples ? batch_size : num_samples - j;

      for (int k = 0; k < batch_sample_count; ++k) {
        batch_samples.push_back(samples[j + k]);
      }

      prg->Inference(batch_samples);
    }
  }
  else { // must be Server
    mtx_samples_queue.lock();
    // There should only ever be one sample issued at a time in server mode
    samples_queue.emplace_back(samples[0]);
    if(samples_queue.size() == prg->settings->qaic_batch_size) {
      prg->Inference(samples_queue);
      samples_queue.clear();
      prev = std::chrono::steady_clock::now();
    }
    mtx_samples_queue.unlock();
  }
};

std::mutex mtx_response;
void SystemUnderTestQAIC::QueryResponse(
    std::vector<SizedSample> &samples, std::vector<std::vector<float>> &results) {

  std::vector<mlperf::QuerySampleResponse> responses;
  responses.reserve(samples.size());

  for (int i = 0; i < samples.size(); ++i) {

    if (prg->settings->verbosity_level > 1) {
      //cout << "Query input index: " << samples[i].index
      //     << " -> Predicted class: " << results[i] << " " << endl;
    } else if (prg->settings->verbosity_level) {
      cout << 'p' << flush;
    }

    responses.push_back(
        {samples[i].first.id, uintptr_t(&results[i][0]), sizeof(float)*results[i].size()});
  }
  mtx_response.lock();
  mlperf::QuerySamplesComplete(responses.data(), responses.size());
  mtx_response.unlock();
};

void SystemUnderTestQAIC::FlushQueries() {
  auto vl = prg->settings->verbosity_level;
  if (vl) {
    cout << endl;
  }
};

void SystemUnderTestQAIC::ReportLatencyResults(
    const std::vector<mlperf::QuerySampleLatency> &latencies_ns) {

  size_t size = latencies_ns.size();
  uint64_t avg =
      accumulate(latencies_ns.begin(), latencies_ns.end(), uint64_t(0)) / size;

  std::vector<mlperf::QuerySampleLatency> sorted_lat(latencies_ns.begin(),
                                                     latencies_ns.end());
  sort(sorted_lat.begin(), sorted_lat.end());

  cout << endl
       << "------------------------------------------------------------";
  cout << endl
       << "|            LATENCIES (in nanoseconds and fps)            |";
  cout << endl
       << "------------------------------------------------------------";
  size_t p50 = size * 0.5;
  size_t p90 = size * 0.9;
  cout << endl << "Number of queries run: " << size;
  cout << endl
       << "Min latency:                      " << sorted_lat[0] << "ns  ("
       << 1e9 / sorted_lat[0] << " fps)";
  cout << endl
       << "Median latency:                   " << sorted_lat[p50] << "ns  ("
       << 1e9 / sorted_lat[p50] << " fps)";
  cout << endl
       << "Average latency:                  " << avg << "ns  (" << 1e9 / avg
       << " fps)";
  cout << endl
       << "90 percentile latency:            " << sorted_lat[p90] << "ns  ("
       << 1e9 / sorted_lat[p90] << " fps)";

  if (!prg->settings->trigger_cold_run) {
    cout << endl
         << "First query (cold model) latency: " << latencies_ns[0] << "ns  ("
         << 1e9 / latencies_ns[0] << " fps)";
  }
  cout << endl
       << "Max latency:                      " << sorted_lat[size - 1]
       << "ns  (" << 1e9 / sorted_lat[size - 1] << " fps)";
  cout << endl
       << "------------------------------------------------------------ "
       << endl;
};

class QuerySampleLibraryQAIC : public mlperf::QuerySampleLibrary {
public:
  QuerySampleLibraryQAIC(Program *_prg) : mlperf::QuerySampleLibrary() {
    prg = _prg;
  };

  ~QuerySampleLibraryQAIC() = default;

  const std::string &Name() const override { return name_; }

  size_t TotalSampleCount() override { 
    std::cout << "available input max " << prg->available_inputs_max() << std::endl;
    return prg->available_inputs_max();
  }

  size_t PerformanceSampleCount() override {
    std::cout << "inputs in memory max " << prg->inputs_in_memory_max() << std::endl;
    return prg->inputs_in_memory_max();
  }

  void LoadSamplesToRam(
      const std::vector<mlperf::QuerySampleIndex> &samples) override {

    prg->LoadNextBatch(samples);
    return;
  }

  void UnloadSamplesFromRam(
      const std::vector<mlperf::QuerySampleIndex> &samples) override {
    prg->UnloadBatch(samples);
    return;
  }

private:
  std::string name_{"QAIC_QSL"};
  Program *prg;
};

void TestQAIC(Program *prg) {

  const std::string mlperf_conf_path =
      getenv_s("CK_ENV_MLPERF_INFERENCE_MLPERF_CONF");
  const std::string user_conf_path = getenv_s("CK_LOADGEN_USER_CONF");

  std::string model_name = getenv_opt_s("ML_MODEL_MODEL_NAME", "unknown_model");

  const std::string scenario_string = getenv_s("CK_LOADGEN_SCENARIO");
  const std::string mode_string = getenv_s("CK_LOADGEN_MODE");

  std::cout << "Path to mlperf.conf : " << mlperf_conf_path << std::endl;
  std::cout << "Path to user.conf : " << user_conf_path << std::endl;
  std::cout << "Model Name: " << model_name << std::endl;
  std::cout << "LoadGen Scenario: " << scenario_string << std::endl;
  std::cout << "LoadGen Mode: "
            << (mode_string != "" ? mode_string : "(empty string)")
            << std::endl;

  mlperf::TestSettings ts;

  // This should have been done automatically inside ts.FromConfig() !
  ts.scenario =
      (scenario_string == "SingleStream")  ? mlperf::TestScenario::SingleStream
      : (scenario_string == "MultiStream") ? mlperf::TestScenario::MultiStream
      : (scenario_string == "Server")  ? mlperf::TestScenario::Server
      : (scenario_string == "Offline") ? mlperf::TestScenario::Offline
                                       : mlperf::TestScenario::SingleStream;

  if (mode_string != "")
    ts.mode = (mode_string == "SubmissionRun") ? mlperf::TestMode::SubmissionRun
              : (mode_string == "AccuracyOnly") ? mlperf::TestMode::AccuracyOnly
              : (mode_string == "PerformanceOnly")
                  ? mlperf::TestMode::PerformanceOnly
              : (mode_string == "FindPeakPerformance")
                  ? mlperf::TestMode::FindPeakPerformance
                  : mlperf::TestMode::SubmissionRun;

  if (ts.FromConfig(mlperf_conf_path, model_name, scenario_string)) {
    std::cout << "Issue with mlperf.conf file at " << mlperf_conf_path
              << std::endl;
    exit(1);
  }

  if (ts.FromConfig(user_conf_path, model_name, scenario_string)) {
    std::cout << "Issue with user.conf file at " << user_conf_path << std::endl;
    exit(1);
  }

  mlperf::LogSettings log_settings;
  log_settings.log_output.prefix_with_datetime = false;
  log_settings.enable_trace = false;

  if (prg->settings->trigger_cold_run) {
    prg->ColdRun();
  }

  SystemUnderTestQAIC sut(prg, ts.scenario);
  QuerySampleLibraryQAIC qsl(prg);

  mlperf::StartTest(&sut, &qsl, ts, log_settings);
}

int main(int argc, char *argv[]) {
  try {
    Program *prg = new Program();
    TestQAIC(prg);
    delete prg;
  } catch (const string &error_message) {
    cerr << "ERROR: " << error_message << endl;
    return -1;
  }
  return 0;
}

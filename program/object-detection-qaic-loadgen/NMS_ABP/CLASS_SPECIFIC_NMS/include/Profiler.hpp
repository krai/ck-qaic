//==============================================================================
//
// Copyright (c) 2021 Qualcomm Innovation Center, Inc.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted (subject to the limitations in the
// disclaimer below) provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above
//      copyright notice, this list of conditions and the following
//      disclaimer in the documentation and/or other materials provided
//      with the distribution.
//
//    * Neither the name Qualcomm Innovation Center nor the names of its
//      contributors may be used to endorse or promote products derived
//      from this software without specific prior written permission.
//
// NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE
// GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT
// HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
// WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
// IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//==============================================================================


#ifndef QRANIUM_DEMO_PROFILER_HPP
#define QRANIUM_DEMO_PROFILER_HPP

#include <string>
#include <chrono>
#include <stdio.h>

#ifndef NDEBUG
#define PROFILE(x) Profiler __profile__(x)
#else
#define PROFILE(x)
#endif

class Profiler
{
public:
    Profiler(const std::string& name) : _name(name), _start(std::chrono::system_clock::now()) { }
    virtual ~Profiler() {
        auto temp = (std::chrono::system_clock::now() - _start);
        // printf("Debug - [%s] %ld ms (%ld us)\n",
        //        _name.c_str(),
        //        std::chrono::duration_cast<std::chrono::milliseconds>(temp).count(),
        //        std::chrono::duration_cast<std::chrono::microseconds>(temp).count());
        FILE *fr;
        fr = fopen("timing.log","a+");
        fprintf(fr, "Debug - [%s] %ld ms (%ld us)\n",
               _name.c_str(),
               std::chrono::duration_cast<std::chrono::milliseconds>(temp).count(),
               std::chrono::duration_cast<std::chrono::microseconds>(temp).count());
        fclose(fr);
    }

private:
    std::string _name;
    std::chrono::time_point<std::chrono::system_clock> _start;
};


#endif //QRANIUM_DEMO_PROFILER_HPP

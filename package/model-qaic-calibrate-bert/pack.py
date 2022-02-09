#!/usr/bin/env python3
#
# Copyright (c) 2021 Krai Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

from ast import literal_eval
from collections import defaultdict
from queue import Queue
import numpy as np
import pickle
from pathlib import Path
import sys

input_pickle_blob = Path(sys.argv[1])
output_dir = Path(sys.argv[2])
strategy_set_fp = Path(sys.argv[3])
strategy_count_fp = Path(sys.argv[4])

with open(Path(input_pickle_blob), 'rb') as tokenized_features_file:
    eval_features = pickle.load(tokenized_features_file)


with open(strategy_set_fp) as f:
    strategy_set = literal_eval(f.read())

with open(strategy_count_fp) as f:
    strategy_count = [int(x) for x in f.readlines()]

def pack_and_write_data(data_list, dirpath, max_sl=384):

    input_ids = np.zeros((max_sl), dtype=np.int64)
    segment_ids = np.zeros((max_sl), dtype=np.int64)

    offset = 0
    for feature in data_list:
        seq_len = sum(feature.input_mask)
        input_ids[offset : seq_len+offset] = np.array(feature.input_ids, dtype=np.int64)[0:seq_len]
        segment_ids[offset : seq_len+offset] = np.array(feature.segment_ids, dtype=np.int64)[0:seq_len]
        offset += seq_len

    mask = np.array([[i for i in range(len(data_list)) \
                       for _ in range(sum(data_list[i].input_mask)) ]])
    input_mask = 1 * np.equal(mask, mask.transpose())

    position_ids = np.concatenate([np.arange(sum(x.input_mask), dtype=np.int64) for x in data_list])

    pad_len = max_sl - offset
    input_mask = np.pad(input_mask, [0, pad_len])
    position_ids = np.pad(position_ids, [0, pad_len])

    input_mask = input_mask.astype(bool)

    dirpath.mkdir(exist_ok=True, parents=True)
    input_ids.tofile(dirpath / 'input_ids.raw')
    input_mask.tofile(dirpath / 'input_mask.raw')
    segment_ids.tofile(dirpath / 'segment_ids.raw')
    position_ids.tofile(dirpath / 'input_position_ids.raw')





samples_by_sl = [Queue() for _ in range(384 + 1)]
for idx, feature in enumerate(eval_features):
    samples_by_sl[sum(feature.input_mask)].put(feature)

# iterate over strategy
# and do the packing
output_idx = 0
for group, group_freq in zip(strategy_set, strategy_count):
    # group (list) contains the SL that has to be packed together
    # pack it "group_freq" times
    for _ in range(group_freq):
        # get data to be packed together
        to_pack = []
        for sl in group:
            to_pack.append(samples_by_sl[sl].get_nowait())

        packed_data = pack_and_write_data(to_pack, output_dir / str(output_idx))
        output_idx += 1

# check if packed all
for i in range(384 + 1):
    assert samples_by_sl[i].empty()


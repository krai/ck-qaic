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
from spfhp import pack_using_spfhp

MASK_SL = 8

input_pickle_blob = Path(sys.argv[1])
output_dir = Path(sys.argv[2])
packed_seq_len = int(sys.argv[3])

with open(Path(input_pickle_blob), 'rb') as tokenized_features_file:
    eval_features = pickle.load(tokenized_features_file)

# create a histogram of the sample lengths
histogram = np.zeros(packed_seq_len)
for feature in eval_features:
    histogram[sum(feature.input_mask)-1] += 1

#pack strategy
strategy_set, strategy_count = pack_using_spfhp(histogram, packed_seq_len, 3)

def pack_and_write_data(data_list, dirpath, max_sl):

    input_ids = np.zeros((max_sl), dtype=np.int64)
    segment_ids = np.zeros((max_sl), dtype=np.int64)

    offset = 0
    for feature in data_list:
        seq_len = sum(feature.input_mask)
        input_ids[offset : seq_len+offset] = np.array(feature.input_ids, dtype=np.int64)[0:seq_len]
        segment_ids[offset : seq_len+offset] = np.array(feature.segment_ids, dtype=np.int64)[0:seq_len]
        offset += seq_len


    # input_mask is just the list of sequence lengths
    mask = np.array([sum(x.input_mask) for x in data_list])

    #mask = np.array([[i for i in range(len(data_list)) \
    #                   for _ in range(sum(data_list[i].input_mask)) ]])
    #input_mask = 1 * np.equal(mask, mask.transpose())

    position_ids = np.concatenate([np.arange(sum(x.input_mask), dtype=np.int64) for x in data_list])

    pad_len = max_sl - offset
    position_ids = np.pad(position_ids, [0, pad_len])
    input_mask = np.pad(mask, [0, MASK_SL - len(mask)])

    dirpath.mkdir(exist_ok=True, parents=True)
    input_ids.tofile(dirpath / 'input_ids.raw')
    input_mask.tofile(dirpath / 'input_mask.raw')
    segment_ids.tofile(dirpath / 'segment_ids.raw')
    position_ids.tofile(dirpath / 'input_position_ids.raw')


def pack_and_write_data_new(data_list, max_sl=384):
    # data_list has [[input_ids_0, input_mask_0, segment_ids_0], ...]
    input_ids = np.concatenate([x[0] for x in data_list])
    segment_ids = np.concatenate([x[2] for x in data_list])

    # input_mask is just the list of sequence lengths
    mask = np.array([len(x[0]) for x in data_list])

    # create input_position_ids
    position_ids = np.concatenate([np.arange(len(x[0]), dtype=np.int64) for x in data_list])

    # padding
    pad_len = max_sl - len(input_ids)
    assert pad_len >= 0
    assert len(input_ids) == len(segment_ids)
    input_ids = np.pad(input_ids, [0, pad_len])
    segment_ids = np.pad(segment_ids, [0, pad_len])
    input_mask = np.pad(mask, [0, MASK_SL - len(mask)])
    position_ids = np.pad(position_ids, [0, pad_len])

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
for group, group_freq in zip(strategy_set, strategy_count.astype(int)):
    # group (list) contains the SL that has to be packed together
    # pack it "group_freq" times
    for _ in range(group_freq):
        # get data to be packed together
        to_pack = []
        for sl in group:
            to_pack.append(samples_by_sl[sl].get_nowait())

        packed_data = pack_and_write_data(to_pack, output_dir / str(output_idx), packed_seq_len)
        output_idx += 1

# check if packed all
for i in range(384 + 1):
    assert samples_by_sl[i].empty()


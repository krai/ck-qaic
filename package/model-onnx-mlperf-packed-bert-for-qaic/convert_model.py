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

import json
import os
import re
import sys

import numpy as np

import torch
from transformers import BertConfig, BertTokenizer, BertForQuestionAnswering
import tensorflow as tf

import onnx_graphsurgeon as gs
import onnx

from collections import OrderedDict


with open("./downloaded/bert_config.json") as f:
    config = json.load(f)

# construct the bert config
config = BertConfig(
    attention_probs_dropout_prob=config["attention_probs_dropout_prob"],
    hidden_act=config["hidden_act"],
    hidden_dropout_prob=config["hidden_dropout_prob"],
    hidden_size=config["hidden_size"],
    initializer_range=config["initializer_range"],
    intermediate_size=config["intermediate_size"],
    max_position_embeddings=config["max_position_embeddings"],
    num_attention_heads=config["num_attention_heads"],
    num_hidden_layers=config["num_hidden_layers"],
    type_vocab_size=config["type_vocab_size"],
    vocab_size=config["vocab_size"])


model = BertForQuestionAnswering(config)
model.classifier = model.qa_outputs

# This part is copied from HuggingFace Transformers with a fix to bypass an error
init_vars = tf.train.list_variables("./downloaded/model.ckpt-5474")
names = []
arrays = []
for name, shape in init_vars:
    # print("Loading TF weight {} with shape {}".format(name, shape))
    array = tf.train.load_variable("./downloaded/model.ckpt-5474", name)
    names.append(name)
    arrays.append(array)

for name, array in zip(names, arrays):
    name = name.split("/")
    # adam_v and adam_m are variables used in AdamWeightDecayOptimizer to calculated m and v
    # which are not required for using pretrained model
    if any(n in ["adam_v", "adam_m", "global_step"] for n in name):
        print("Skipping {}".format("/".join(name)))
        continue
    pointer = model
    for m_name in name:
        if re.fullmatch(r"[A-Za-z]+_\d+", m_name):
            scope_names = re.split(r"_(\d+)", m_name)
        else:
            scope_names = [m_name]
        if scope_names[0] == "kernel" or scope_names[0] == "gamma":
            pointer = getattr(pointer, "weight")
        elif scope_names[0] == "output_bias" or scope_names[0] == "beta":
            pointer = getattr(pointer, "bias")
        elif scope_names[0] == "output_weights":
            pointer = getattr(pointer, "weight")
        elif scope_names[0] == "squad":
            pointer = getattr(pointer, "classifier") # This line is causing the issue
        else:
            try:
                pointer = getattr(pointer, scope_names[0])
            except AttributeError:
                print("Skipping {}".format("/".join(name)))
                continue
        if len(scope_names) >= 2:
            num = int(scope_names[1])
            pointer = pointer[num]
    if m_name[-11:] == "_embeddings":
        pointer = getattr(pointer, "weight")
    elif m_name == "kernel":
        array = np.transpose(array)
    try:
        assert pointer.shape == array.shape
    except AssertionError as e:
        e.args += (pointer.shape, array.shape)
        raise
    print("Initialize PyTorch weight {}".format(name))
    pointer.data = torch.from_numpy(array)

model.qa_outputs = model.classifier
del model.classifier

tokenizer = BertTokenizer.from_pretrained("bert-large-uncased-whole-word-masking-finetuned-squad")
model = model.eval()
dummy_input = torch.ones((1, 384), dtype=torch.int64)

torch.onnx.export(
    model,
    (dummy_input, dummy_input, dummy_input),
    "./intermediate_model.onnx",
    verbose=True,
    input_names = ["input_ids", "input_mask", "segment_ids"],
    output_names = ["output_start_logits", "output_end_logits"],
    opset_version=11,
    dynamic_axes=({"input_ids": {0: "batch_size", 1: "seg_length"}, "input_mask": {0: "batch_size", 1: "seg_length"}, 
                   "segment_ids": {0: "batch_size", 1: "seg_length"}, "output_start_logits": {0: "batch_size", 1: "seg_length"}, 
                   "output_end_logits": {0: "batch_size", 1: "seg_length"}})
)

def remove_node(node):
    for inp in node.inputs:
        inp.outputs.clear()
    # Disconnet input nodes of all output tensors
    for out in node.outputs:
        out.inputs.clear()

@gs.Graph.register()
def add_2d_mask(self, inputs, outputs):
    inp1 = inputs[0]
    inp1.shape = ['batch_size', 'seg_length', 'seg_length']
    inp1.dtype = np.bool
    
    # Disconnect output nodes of all input tensors
    for inp in inputs:
        inp.outputs.clear()
    # Disconnet input nodes of all output tensors
    for out in outputs:
        for out2 in out.outputs:
            output_copy = list(out2.outputs)
            remove_node(out2)
        remove_node(out)
    # Insert the new node.
    return self.layer(op="Unsqueeze", name='', attrs=OrderedDict([('axes', [1])]), inputs=[inp1], outputs=output_copy)

def add_position_input(graphPacked):
    collectGatherNodes = [node for node in graph.nodes if node.op == "Gather"]
    for gather in collectGatherNodes:
        if gather.inputs[0].name == "bert.embeddings.position_embeddings.weight":
            positionInput = gs.Variable(name="input_position_ids", dtype=np.int64, shape=("batch_size", 'seg_length'))
            gather.inputs[1] = positionInput
            graphPacked.inputs.append(positionInput)
    
    return graphPacked

modelFloat = onnx.load("./intermediate_model.onnx")
graph = gs.import_onnx(modelFloat)
for node in graph.nodes:
    if len(node.inputs) > 0 and node.inputs[0].name == "input_mask":
        graph.add_2d_mask(node.inputs, node.outputs)
        break

graph = add_position_input(graph)
graph.cleanup().toposort()

os.remove("./intermediate_model.onnx")
onnx.save(gs.export_onnx(graph), "./model.onnx")


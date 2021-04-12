# =============================================================================
#  @@-COPYRIGHT-START-@@
#
#  Copyright (c) 2021, Qualcomm Innovation Center, Inc. All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#  3. Neither the name of the copyright holder nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
#  SPDX-License-Identifier: BSD-3-Clause
#
#  @@-COPYRIGHT-END-@@
# =============================================================================
import types

import torch
from torch import nn
from torch.nn import functional as F
import torchvision
from torchvision.models.resnet import resnet34

class Concat(torch.nn.Module):
    """ Concat module for a functional concat"""
    def __init__(self, axis: int = 0):
        super(Concat, self).__init__()
        self.axis = axis

    # expects inputs to be list or tuple
    def forward(self, *inputs):
        return torch.cat(inputs, self.axis)

def _forward_block(self, x):
    identity = x
    out = self.conv1(x)
    out = self.bn1(out)
    out = self.relu(out)

    out = self.conv2(out)
    out = self.bn2(out)

    if self.downsample is not None:
        identity = self.downsample(x)

    out += identity
    out = self.relu2(out)

    return out

def _forward_bottleneck(self, x):
    identity = x

    out = self.conv1(x)
    out = self.bn1(out)
    out = self.relu(out)

    out = self.conv2(out)
    out = self.bn2(out)
    out = self.relu2(out)

    out = self.conv3(out)
    out = self.bn3(out)

    if self.downsample is not None:
        identity = self.downsample(x)

    out += identity
    out = self.relu3(out)

    return out

def bbox_view(self, src, loc, conf,extract_shapes=False):
    ret = []
    features_shapes = []
    for s, l, c in zip(src, loc, conf):
        ret.append((l(s).view(s.size(0), 4, -1), c(s).view(s.size(0), self.label_num, -1)))
        if extract_shapes:
            ls=l(s)
            features_shapes.append([ls.shape[2],ls.shape[3]])
    locs, confs = list(zip(*ret))
    locs = tuple(locs)
    confs = tuple(confs)
    locs = self.catModule1(*locs).contiguous()
    confs = self.catModule2(*confs).contiguous()
    return locs, confs,features_shapes

def forward(self, data):
    layers = self.model(data)

    x = layers[-1]
    
    additional_results = []
    for i, l in enumerate(self.additional_blocks):
        
        x = l(x)
        additional_results.append(x)

    src = [*layers, *additional_results]
    locs, confs,features_shapes = self.bbox_view(src, self.loc, self.conf,extract_shapes=self.extract_shapes)
    if self.run_type == 'export':
        confs = confs.permute(0, 2, 1)
        confs_transformed = torch.nn.functional.softmax(confs, dim=2)
        confs_transformed = confs_transformed.permute(0, 2, 1)
        return locs,confs_transformed
    else:
        return locs,confs

def model_modifications(model, params, mod_type='export'):
    # common to both sets of modifications
    if getattr(model, 'catModule1', None) is None:
        model.forward = types.MethodType(forward, model)
        model.bbox_view = types.MethodType(bbox_view, model)

        model.catModule1 = Concat(2)
        model.catModule2 = Concat(2)

        for name,module in model.named_modules():
            if isinstance(module, torchvision.models.resnet.BasicBlock):
                relu2 = nn.ReLU(inplace=True)
                module.relu2 = relu2
                module.forward = types.MethodType(_forward_block, module)
            elif isinstance(module, torchvision.models.resnet.Bottleneck):
                relu2 = nn.ReLU(inplace=True)
                relu3 = nn.ReLU(inplace=True)
                module.relu2 = relu2
                module.relu3 = relu3
                module.forward = types.MethodType(_forward_bottleneck, module)

    model.run_type = mod_type
    if mod_type == 'export':
        model.non_max_suppression_module = None
        model.anchor_scaling = None
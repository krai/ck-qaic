#
# Copyright (c) 2015-2019 cTuning foundation.
# Copyright (c) 2019-2020 dividiti Limited.
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

import os
import re


##############################################################################
def version_cmd(i):
    apps_xml_path = '/opt/qti-aic/versions/apps.xml'
    version = ''
    with open(apps_xml_path) as apps_xml_file:
        apps_xml_lines = apps_xml_file.readlines()
        for line in apps_xml_lines:
            base_version_match = re.search('<base_version>([\d\.]*)</base_version>', line)
            if base_version_match:
                base_version = base_version_match.group(1)
                version = base_version
            build_id_match = re.search('<build_id>(\d*)</build_id>', line)
            if build_id_match:
                build_id = build_id_match.group(1)
                version += '.' + build_id
    return {'return':0, 'cmd':'', 'version':version}


##############################################################################
def setup(i):
    """
    Input:  {
              cfg              - meta of this soft entry
              self_cfg         - meta of module soft
              ck_kernel        - import CK kernel module (to reuse functions)

              host_os_uoa      - host OS UOA
              host_os_uid      - host OS UID
              host_os_dict     - host OS meta

              target_os_uoa    - target OS UOA
              target_os_uid    - target OS UID
              target_os_dict   - target OS meta

              target_device_id - target device ID (if via ADB)

              tags             - list of tags used to search this entry

              env              - updated environment vars from meta
              customize        - updated customize vars from meta

              deps             - resolved dependencies for this soft

              interactive      - if 'yes', can ask questions, otherwise quiet
            }

    Output: {
              return       - return code =  0, if successful
                                         >  0, if error
              (error)      - error text if return > 0

              bat          - prepared string for bat file
            }

    """

    import os

    ck              = i['ck_kernel']
    cus             = i.get('customize',{})
    full_path       = cus.get('full_path','')
    env             = i['env']
    install_root    = os.path.dirname(full_path)
    install_env     = cus.get('install_env', {})
    env_prefix      = cus['env_prefix']

    env[env_prefix + '_ROOT']     = install_root
    env[env_prefix + '_FILENAME'] = full_path

    stem = full_path[:-len('xml')]
    env[env_prefix + '_XML']      = stem+'xml'
    env[env_prefix + '_BIN']      = stem+'bin'
    env[env_prefix + '_MAPPING']  = stem+'mapping'

    # This group should end with _FILE prefix e.g. FLATLABELS_FILE
    # This suffix will be cut off and prefixed by cus['env_prefix']
    # so we'll get vars like CK_ENV_TENSORRT_MODEL_FLATLABELS_FILE
    for varname in install_env.keys():
        if varname.endswith('_FILE'):
            file_path = os.path.join(install_root, install_env[varname])
            if os.path.exists(file_path):
                env[env_prefix + '_' + varname] = file_path

    # Just copy those without any change in the name:
    #
    for varname in install_env.keys():
        if varname.startswith('ML_MODEL_') or varname.startswith('CK_MLPERF_'):
            env[varname] = install_env[varname]
            # These variables are expected to be stipped of "CK_ENV"
        elif varname.startswith('_ONNX_MODEL_') or varname.startswith('_TENSORFLOW_MODEL_') or varname.startswith('_ABC_LOC_') or varname.startswith('COMPILER'):
            env["CK_ENV" + varname] = install_env[varname]

    
    return {'return':0, 'bat':''}

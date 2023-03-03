#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *

mode = 'performance'
# ==========================================================================================================================
# Scenario Target Value
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_scenario_target_value( implementation_model, sut_scenario_target, value, sdk):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
    if skip_tests(model, scenario, sut) != '':
        return 
         
    i = ck_cmdgen_args( data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk )
        
    # Act
    r=ck.access(i)
    return_code = r['return']
    
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
    
    # Assert
    if scenario in [ 'offline', 'server' ]:
        match = re.search(r'--env.CK_LOADGEN_TARGET_QPS=(\d*\.?\d*)', cmd)
    elif scenario in [ 'singlestream', 'multistream' ]:
        match = re.search(r'--env.CK_LOADGEN_TARGET_LATENCY=(\d*\.?\d*)', cmd)
    assert match
    assert match.group(1) == value

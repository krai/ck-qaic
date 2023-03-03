#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *

mode = 'accuracy'
# ==========================================================================================================================
# No Target
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_accuracy_no_target( implementation_model, sut, scenario_target, sdk ):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    scenario = scenario_target[0]
    
    if skip_tests( model, scenario, sut) != '':
        return 
         
    i = ck_cmdgen_args(data_uoa=implementation, model = model, sut = sut,
                        scenario = scenario, mode = mode, sdk = sdk)
    
    # Act
    # Check that only one command is generated.
    r=ck.access(i)
    return_code = r['return']
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
    
    # Assert
    # Check that the target latency is not added to the record name.
    match_name = re.search(r'record_uoa.*-target_latency.(\d*\.?\d*)', cmd)
    assert match_name == None

# ==========================================================================================================================
# One target
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_accuracy_one_target(implementation_model, sut, scenario_target, value, sdk):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    scenario = scenario_target[0]
    target = scenario_target[1]
    if skip_tests( model, scenario, sut) != '':
        return 
    
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                         target = target , value = value, mode = mode, sdk = sdk)
       
    # Act
    # Check that only one command is generated.
    r=ck.access(i)
    return_code = r['return']
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
    
    # Assert
    # Check that if the target latency, if present, is passed to the implementation.
    match_loadgen = re.search(r'--env.CK_LOADGEN_TARGET_LATENCY=(\d*\.?\d*)', cmd)
    assert match_loadgen
    assert match_loadgen.group(1) == value
    
# ==========================================================================================================================
# Two targerts
# ==========================================================================================================================
# @pytest.mark.skip    
def test_cmdgen_accuracy_two_targets(implementation_model, sut, scenario_target1_target2, value1_value2, sdk):
    # Arrange
    scenario = scenario_target1_target2[0]
    target1 = scenario_target1_target2[1]
    target2 = scenario_target1_target2[2]
    value1 = value1_value2[0]
    value2 = value1_value2[1]
    model = implementation_model[1]
    implementation = implementation_model[0]
    
    if skip_tests(model , scenario, sut) != '':
        return 
    
    i = ck_cmdgen_args( data_uoa = implementation, model = model, sut = sut,
                        scenario = scenario, target = target1, value = value1, 
                        mode = mode, sdk = sdk, target2 = target2, value2= value2 )
    # Act
    # Check that only one command is generated.
    r=ck.access(i)
    return_code = r['return']
    assert return_code == 0
    cmds = r.get('cmds')
    assert len(cmds) == 1
    cmd = cmds[0]
    
    # Assert
    # Check that if the target latency, if present, is passed to the implementation.
    # TODO assert for both targets??
    match_loadgen = re.search(r'--env.CK_LOADGEN_TARGET_LATENCY=(\d*\.?\d*)', cmd)
    assert match_loadgen
    assert match_loadgen.group(1) == value1
        

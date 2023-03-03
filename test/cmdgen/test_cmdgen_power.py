#!/usr/bin/python3

import re
import ck.kernel as ck
from helper_functions import *

mode = 'performance'
power_server_port = '4949'
power_server_ip = '4.5.7.8'
power = 'yes'
    
# ==========================================================================================================================
# No Power
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_no_power(implementation_model, sut_scenario_target, value, sdk):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1] 
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
    if skip_tests( model, scenario, sut ) != '':
        return 
         
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk)
    
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Assert
    # Match power.
    match = re.search(r'power', cmd)
    assert match == None
    
# ==========================================================================================================================
# Option 2: With Power
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_with_power( implementation_model, sut_scenario_target, value, sdk ):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
    # Skip irrelevant tests
    if skip_tests( model, scenario, sut) != '':
        return 
        
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk, power = power)
    
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Assert
    # Match power.
    match = re.search(r'power', cmd)
    assert match
    assert match.group(0) == 'power'
    
    port_ip = get_port_for_sut(sut_scenario_target[0])
    port = port_ip.get('port')
    ip = port_ip.get('ip')
    
    # Match power port.
    
    match_power_port = re.search(r'POWER_CLIENT_PORT=(\d+)', cmd)
    assert match_power_port
    assert match_power_port.group(1) == port
    
    # Match IP Address.
    match_power_ip = re.search(r'POWER_CLIENT_ADDRESS=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', cmd)
    assert match_power_ip
    assert match_power_ip.group(1) == ip
    
    
# ==========================================================================================================================
# Option 3: Power measurements with an overriden power server port
# ==========================================================================================================================
# @pytest.mark.skip
def test_cmdgen_power_port_overriden( implementation_model, sut_scenario_target, value, sdk ):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
     # Skip irrelevant tests
    if skip_tests( model, scenario, sut) != '':
        return  
     
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk, power = power, 
                       power_server_port = power_server_port)
    
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Assert
    
    # Match power.
    match = re.search(r'power', cmd)
    assert match
    assert match.group(0) == 'power'
    
    # Match power port.
    match_power_port = re.search(r'POWER_CLIENT_PORT=(\d+)', cmd)
    assert match_power_port
    assert match_power_port.group(1) == power_server_port
    
# ==========================================================================================================================
# Option 4 - power measurements with an overriden power server ip 
# ==========================================================================================================================

# @pytest.mark.skip
def test_cmdgen_power_ip_overriden(implementation_model, sut_scenario_target, value, sdk):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
    # Skip irrelevant tests
    if skip_tests( model, scenario, sut ) != '':
        return 
    
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk, power = power, 
                       power_server_ip = power_server_ip )
        
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Assert
    
    # Match power.
    match = re.search(r'power', cmd)
    assert match
    assert match.group(0) == 'power'
    
    # Match IP Address.
    match_power_ip = re.search(r'POWER_CLIENT_ADDRESS=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', cmd)
    assert match_power_ip
    assert match_power_ip.group(1) == power_server_ip
    
# ==========================================================================================================================
# Option 5 - power measurements with both the port and ip overriden
# ==========================================================================================================================

# @pytest.mark.skip
def test_cmdgen_power_port_ip_overriden(implementation_model, sut_scenario_target, value, sdk):
    # Arrange
    implementation = implementation_model[0]
    model = implementation_model[1]
    sut = sut_scenario_target[0]
    scenario = sut_scenario_target[1]
    target = sut_scenario_target[2]
    
    # Skip irrelevant tests
    if skip_tests( model, scenario, sut ) != '':
        return 
    
    i = ck_cmdgen_args(data_uoa = implementation, model = model, sut = sut, scenario = scenario,
                       target = target, value = value, mode = mode, sdk = sdk, power = power, 
                       power_server_port = power_server_port, power_server_ip = power_server_ip )
    # Act
    cmd = ck_cmdgen_command(i)
        
    # Assert
    
    # Match power.
    match = re.search(r'power', cmd)
    assert match
    assert match.group(0) == 'power'
    
    # Match power port.
    match_power_port = re.search(r'POWER_CLIENT_PORT=(\d+)', cmd)
    assert match_power_port
    assert match_power_port.group(1) == power_server_port
    
    # Match IP Address.
    match_power_ip = re.search(r'POWER_CLIENT_ADDRESS=(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', cmd)
    assert match_power_ip
    assert match_power_ip.group(1) == power_server_ip
    
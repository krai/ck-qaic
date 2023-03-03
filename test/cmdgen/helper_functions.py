import ck.kernel as ck

#----------------------------------------------------------------------------------------------------   
# Generate CK Arguments
#----------------------------------------------------------------------------------------------------   
def ck_cmdgen_args(**cmdgen_args):
    
    cmd = {'action':'gen', 'module_uoa':'cmdgen'}
    
    # simple arguments
    for key, value in cmdgen_args.items():
        if value != 'no' and key not in ('target', 'target2', 'value', 'value2', 'device_ids', 'device_ids_value') :
            cmd.update({ key: value })
            
    # key: value arguments
    if cmdgen_args.get('target') and cmdgen_args.get('value'):       
        cmd.update({ cmdgen_args.get('target'): cmdgen_args.get('value')})    
        
    if cmdgen_args.get('target2') and cmdgen_args.get('value2'):       
        cmd.update({ cmdgen_args.get('target2'): cmdgen_args.get('value2')})    
        
    if cmdgen_args.get('device_ids') and cmdgen_args.get('device_ids_value'):       
        cmd.update({ cmdgen_args.get('device_ids'): cmdgen_args.get('device_ids_value')})        
                
    return cmd
#---------------------------------------------------------------------------------------------------- 
  
# Generate CK Arguments
    # 1 - implementation, 
    # 2 - model, 
    # 3 - sut,
    # 4 - scenario,
    # 5 - target,
    # 6 - value,
    # 7 - mode,
    # 8 - sdk, 
    # 9 - timestamp, 
    # 10 - power,
    # 11 - power_server_port,
    # 12 - power_server_ip, 
    # 13 - soc_reset
    # 14 - value_ids
    # 15 - target2
    # 16 - value2
#----------------------------------------------------------------------------------------------------   
def ck_cmdgen_params(implementation, model = None, sut = None, scenario = None, target = None, value = None,
                     mode = None, sdk = None, timestamp = None, power = None, power_server_port = None, 
                     power_server_ip = None, soc_reset = None, target2 = None, value2 = None):
#----------------------------------------------------------------------------------------------------   
  
    cmd = {'action':'gen', 'module_uoa':'cmdgen'}
    cmd.update({ 'data_uoa': implementation })
    if model:
        cmd.update({ 'model': model })
    if sut :     
        cmd.update({ 'sut':sut} )
    if scenario :    
        cmd.update({ 'scenario': scenario })
    if target != None and value != None:
        cmd.update({ target: value})
    if target2 != None and value2 != None:
        cmd.update({ target2: value2})    
    if mode: 
        cmd.update({ 'mode': mode })
    if sdk:
        cmd.update({ 'sdk': sdk })
    if timestamp == 'yes': 
        cmd.update({'timestamp': timestamp})
    if power == 'yes': 
        cmd.update({'power': power})
    if power_server_port: 
        cmd.update({'power_server_port': power_server_port})
    if power_server_ip: 
        cmd.update({'power_server_ip': power_server_ip})
    if soc_reset == 'yes':
        cmd.update({'soc_reset': 'soc_reset'})        
    return cmd

#----------------------------------------------------------------------------------------------------   
# Get Command from CK
#----------------------------------------------------------------------------------------------------   
def ck_cmdgen_command(i):
    r = ck.access(i)
    return_code = r['return']
    
    if return_code != 0:
        return SystemError
    elif return_code == 0:
        cmds = r.get('cmds')
        assert len(cmds) == 1
        return cmds[0]
    
# Skip tests
def skip_tests( model, scenario, sut, mode=None):
    # No multistream for bert-99.
    if model == 'bert-99' and scenario == 'multistream': 
        return 'skip'
    # No bert-99.9 for edge.
    if model == 'bert-99.9' and 'edge' in sut: 
        return 'skip'
            
    return ''

#----------------------------------------------------------------------------------------------------   
# Get IP from SUT
#----------------------------------------------------------------------------------------------------   
def get_port_for_sut(sut):
    sut_port = { 'q4_std_edge': { 'port': '4980', 'ip' : '10.222.146.209' },
                 'q4_pro_dc': { 'port': '4915', 'ip' : '10.222.146.209' } 
    }
    return sut_port.get(sut)
    
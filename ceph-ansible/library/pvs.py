#!/bin/env python
from ansible.module_utils.basic import *
import json
import re, sys
import subprocess

def pvs(device):
    args = ["pvs"]
    if device:
        args.append(str(device))
    try:
        pv_output = subprocess.run().stdout
    except AttributeError:
        pv_output = subprocess.check_output(["pvs"])
    pv_output_lines = pv_output.splitlines()
    lvgs = []
    for l in pv_output_lines[1:]:
        words = l.split()
        lvg = words[1]
        lvgs.append(lvg)
    return lvgs

if __name__ == '__main__':
  fields = {
    "device": {"required": False, "type": "str"},
  }
  module = AnsibleModule(argument_spec=fields,
                        supports_check_mode=True, # Ignore
                         )
  device = module.params["device"]
  lvgs = pvs(device)
  module.exit_json(lvgs=lvgs)
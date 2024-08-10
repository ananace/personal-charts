#!/bin/env python

import glob
import os
import re
import yaml


def expand_macro(inp, fulldict):
    key, data = inp
    if type(data) is dict:
        return key, expand_macros(data, fulldict)
    elif type(data) is str:
        newdata = data
        for macro in re.finditer(r"%{([^:]+):([^}]+)}%?", data):
            repl = ""
            method, data = macro[1], macro[2]
            match method:
                case 'env':
                    try:
                        repl = os.environ[data]
                    except Exception as e:
                        print(f"Failed to read env var {data} - {e}")
                        repl = ''
                case 'file':
                    try:
                        with open(data, 'r') as file:
                            repl = file.read(1024 * 1024)
                    except Exception as e:
                        print(f"Failed to read file {file} - {e}")
                        repl = ''
                case 'cfg':
                    value = fulldict
                    try:
                        for iter in data.split('.'):
                            value = value[iter]
                    except Exception as e:
                        print(f"Failed to read config key {data} - {e}")
                        value = ''
                    repl = value
            newdata = newdata.replace(macro[0], repl)
        data = newdata
    return key, data


def expand_macros(inp, fulldict=None):
    if fulldict is None:
        fulldict = inp

    ret = dict(map(lambda item: expand_macro(item, fulldict), inp.items()))
    return ret


data = {}
with open('/synapse/config/homeserver.yaml', 'r') as file:
    data.update(yaml.safe_load(file))
for filename in glob.glob('/synapse/secrets/*.ymal'):
    with open(filename, 'r') as file:
        data.update(yaml.safe_load(file))
for filename in glob.glob('/synapse/config/conf.d/*.ymal'):
    with open(filename, 'r') as file:
        data.update(yaml.safe_load(file))

expanded = expand_macros(data)
print(yaml.dump(expanded))

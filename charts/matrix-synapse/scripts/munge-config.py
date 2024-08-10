#!/bin/env python

import os
import re
import sys
import yaml


def expand_macro(inp, fulldict):
    """
    Expands macros in the configuration, supported syntax is;
    %{env:ENVIRONMENT_VARIABLE}%
    %{file:/path/to/file}%
    %{cfg:path.to.config}%

    Adding a ! before the macro name will remove the key from the configuration
    if it is missing.
    """
    key, data = inp
    remove_key = False
    if type(data) is dict:
        return key, expand_macros(data, fulldict)
    elif type(data) is str:
        newdata = data
        for macro in re.finditer(r"%{([^:]+):([^}]+)}%?", data):
            repl = ""
            remove_if_missing = False
            method, data = macro[1], macro[2]
            if method[0] == '!':
                remove_if_missing = True
                method = method[1:]
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
            if remove_if_missing and not repl:
                remove_key = True
            else:
                newdata = newdata.replace(macro[0], repl)
        data = newdata
    if remove_key:
        return None
    return key, data


def expand_macros(inp, fulldict=None):
    if fulldict is None:
        fulldict = inp

    ret = dict(map(lambda item: expand_macro(item, fulldict), inp.items()))
    return ret


data = {}
if len(sys.argv) > 1:
    for filename in sys.argv[1:]:
        with open(filename, 'r') as file:
            data.update(yaml.safe_load(file))
else:
    with open('/synapse/config/homeserver.yaml', 'r') as file:
        data.update(yaml.safe_load(file))
    try:
        for filename in os.listdir('/synapse/secrets'):
            if not re.match(r"\.ya?ml", filename):
                continue
            with open(os.path.join('/synapse/secrets', filename), 'r') as file:
                data.update(yaml.safe_load(file))
    except FileNotFoundError:
        # No extra secrets provided, ignoring.
        pass

expanded = expand_macros(data)
print(yaml.dump(expanded))

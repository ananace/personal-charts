#!/bin/env python

import argparse
import os
import re
import subprocess
import yaml


def expand_macro(inp, fulldict, path=''):
    """
    Expands macros in the configuration, supported syntax is;
    %{env:ENVIRONMENT_VARIABLE}%
    %{file:/path/to/file}%
    %{cfg:path.to.config}%
    %{cmd:command to run}%
    %{cmd_list:command to run, replaces the entire value with a list of lines}%
    %{cmd_dict:command to run, replaces the entire value with JSON/YAML}%

    Adding a - before the macro name will resolve the macro into the empty
    string on failure.
    Adding a ! before the macro name will also remove the key entirely from the
    configuration if it fails - i.e. a missing file or environment variable,
    or a failing command.
    """
    key, data = inp
    fullkey = f"{path}.{key}".lstrip('.')
    remove_key = False
    if type(data) is dict:
        return key, expand_macros(data, fulldict, path=fullkey)
    elif type(data) is list:
        return key, expand_macros(data, fulldict, path=fullkey)
    elif type(data) is str:
        newdata = data
        for macro in re.finditer(r"%{([^:]+):([^}]+)}%?", data):
            repl = ""
            remove_if_missing = False
            allow_failure = False
            method, data = macro[1], macro[2]
            if method[0] == '-':
                allow_failure = True
                method = method[1:]
            elif method[0] == '!':
                allow_failure = True
                remove_if_missing = True
                method = method[1:]

            if method[0] == '-' or method[0] == '!':
                raise RuntimeError('Only one of ! and - can be used')

            match method:
                case 'env':
                    try:
                        repl = os.environ[data]
                    except Exception:
                        if not allow_failure:
                            raise
                        print(f"{fullkey}: Failed to read env var {data}")
                        repl = ''
                case 'file':
                    try:
                        with open(data, 'r') as file:
                            repl = file.read(1024 * 1024)
                    except Exception:
                        if not allow_failure:
                            raise
                        print(f"{fullkey}: Failed to read file {file}")
                        repl = ''
                case 'cfg':
                    value = fulldict
                    try:
                        for iter in data.split('.'):
                            value = value[iter]
                    except Exception:
                        if not allow_failure:
                            raise
                        print(f"{fullkey}: Failed to read config {data}")
                        value = ''
                    repl = value
                case 'cmd' | 'cmd_list' | 'cmd_dict':
                    try:
                        result = subprocess.run(data,
                                                stdout=subprocess.PIPE,
                                                shell=True,
                                                check=True)
                        value = result.stdout.decode().strip()

                        if method == 'cmd_list':
                            value = value.splitlines()
                        elif method == 'cmd_dict':
                            value = yaml.safe_load(value)
                    except Exception:
                        if not allow_failure:
                            raise
                        print(f"{fullkey}: Failed to run command {data}")
                        value = ''
                    repl = value
                case _:
                    if allow_failure:
                        print(f"{fullkey}: Unknown macro method {method}")
                    else:
                        raise RuntimeError(f"Unknown macro method {method}")

            if remove_if_missing and not repl:
                remove_key = True
            elif type(repl) is not str:
                newdata = repl
            else:
                newdata = newdata.replace(macro[0], repl)
        data = newdata
    if remove_key:
        return None
    return key, data


def expand_macros(inp, fulldict=None, path=""):
    if fulldict is None:
        fulldict = inp

    if type(inp) is list:
        ret = filter(
            lambda item: item is not None,
            [
                expand_macro([idx, v], fulldict, path=path)
                for idx, v in enumerate(inp)
            ]
        )
        ret = [value[1] for value in ret]
    else:
        ret = dict(
            filter(
                lambda item: item is not None,
                map(
                    lambda item: expand_macro(item, fulldict, path=path),
                    inp.items()
                )
            )
        )
    return ret


parser = argparse.ArgumentParser()
parser.add_argument('filenames', nargs='*')
parser.add_argument('-o', '--output')
args = parser.parse_args()

data = {}
if len(args.filenames) > 0:
    for filename in args.filenames:
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
if args.output:
    with open(args.output, 'w') as destination:
        destination.write(yaml.dump(expanded))
else:
    print(yaml.dump(expanded))

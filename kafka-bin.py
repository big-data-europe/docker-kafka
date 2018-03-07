#!/usr/bin/python3
# -*- coding: utf-8 -*-

# this python script will execute any call that the JSON file passed as an argument describes
# the form of this JSON should be like:
#   [
#     {
#       "sh": "some-shell-script.sh",
#       "option": "single-value-option",
#       "list-option: [
#                "list-option-1",
#                "list-option-2"
#       ]
#     },
#     {
#       "sh": "some-other-shell-script.sh"
#     }
#   ]
#
# this will then be converted to as many commands as the json-array holds objects
# for the example above the result will be that the following 2 commands are run:
#     sh some-shell-script.sh option single-value option list-option list-option-1 list-option list-option-2
#     sh some-other-shell-script.sh

import os,sys,collections
import subprocess as sp
import json
import types

class KafkaBin:

    def fromJson(self, kafka_commands_file_name=None):

        if(kafka_commands_file_name==None):
            raise ValueError("the absolute path to the topic definition cannot be none");

        kafka_commands_file_name = os.path.abspath(kafka_commands_file_name);

        with open(kafka_commands_file_name) as kafka_commands_file:
            kafka_commands = json.load(kafka_commands_file,object_pairs_hook=collections.OrderedDict);
            dev_null = open(os.devnull, 'w')
            for command in kafka_commands:
                command_call=[]
                for command_start, command_end in command.items():
                    if(isinstance(command_end, list)):
                        for option in command_end:
                            if(len(option) > 0):
                                command_call.append(str(command_start))
                                command_call.append(str(option))
                    else:
                        command_call.append(str(command_start))
                        if(len(command_end) > 0):
                            command_call.append(str(command_end))
                print("[!] command call about to be executed: " + str(command_call))
                if command_call[0] == "sh":
                    exit_code = sp.call(command_call, stderr=dev_null,close_fds=True)
                else:
                    raise Exception("json construct must start with 'sh' and the path to a kafka binary");

        pass;

if __name__ == '__main__':
    if(len(sys.argv)==2):
        kafkaBin = KafkaBin();
        try :
            kafkaBin.fromJson(sys.argv[1]);
        except Exception as e:
            print(e);
    else:
        print("Please specify a kafka command json")

#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os,sys,collections
import subprocess as sp
import json

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
                [command_call.extend([k,(os.environ[v[1:]] if v.startswith('$') else v)]) for k,v in command.items()]
                command_call = [var for var in command_call if var]
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

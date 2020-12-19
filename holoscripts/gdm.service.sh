#!/usr/bin/bash

#sed '/^Type=/d;/^\[Service\]$/aType=idle'
sed '/^ExecStartPre=/d;/^\[Service\]$/aExecStartPre=/bin/sleep 5'

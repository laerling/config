#!/usr/bin/bash

sed '/^Exec=/s/qjackctl/pw-jack \/usr\/bin\/&/'

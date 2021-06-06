#!/usr/bin/bash

sed '/^Exec=/s/ardour6/pw-jack \/usr\/bin\/&/'

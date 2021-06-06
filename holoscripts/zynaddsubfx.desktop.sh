#!/usr/bin/bash

sed '/^Exec=/s/zynaddsubfx/pw-jack \/usr\/bin\/&/'

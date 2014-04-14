#!/bin/sh

uptime | cut -f 4-7 -d , | cut -f 2  -d \: | sed -e 's/,/\t/g'

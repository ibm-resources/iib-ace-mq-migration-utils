#!/bin/bash

NODE="$1"
mqsilist $NODE | grep 'Integration server' | cut -d' ' -f4 | sed "s/'//g"

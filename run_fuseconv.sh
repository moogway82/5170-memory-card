#!/bin/sh -ex

export PYTHONPATH=~/code/prjbureau
python3 -m util.fuseconv -d ATF1508AS at_memory_card_128k_only.jed at_memory_card_128k_only.svf

#!/bin/sh -ex

export PYTHONPATH=~/code/prjbureau
python3 -m util.fuseconv -d ATF1508AS at_memory_card.jed at_memory_card.svf

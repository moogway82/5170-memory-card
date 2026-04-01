#!/bin/sh -ex

export PYTHONPATH=~/code/prjbureau
NAME=$1; shift
python3 -m util.fuseconv -d ATF1508AS ${NAME}.jed ${NAME}.svf

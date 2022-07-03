#!/bin/bash

set -x
set -u

# get initial path before changing it
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd ./unittest/IlmCtl/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmCtlTest 
cd ../IlmCtlMath/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmCtlMathTest 
cd ../IlmImfCtl/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmImfCtlTest

# go back to initial path
cd $SCRIPTPATH

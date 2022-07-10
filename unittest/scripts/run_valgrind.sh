#!/bin/bash

set -x
set -u

# get initial path before changing it
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd ./unittest/IlmCtl/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmCtlTest
test1_status=$? 

cd ../IlmCtlMath/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmCtlMathTest 
test_02_status=$? 

cd ../IlmImfCtl/
valgrind -s --error-exitcode=1 --leak-check=full --track-origins=yes --show-leak-kinds=all ./IlmImfCtlTest
test_03_status=$? 

# go back to initial path
cd $SCRIPTPATH

# return valgrind exit codes
if [ test_01_status -eq 0 ] && [ test_02_status -eq 0 ] && [ test_03_status -eq 0 ]
then
  echo "Success: valgrind detected no errors"
  exit 0
else
  echo "Failure: valgrind detected errors"
  exit 1
fi

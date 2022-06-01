#!/bin/bash

set -x
set -u

valgrind -s --error-exitcode=1 --leak-check=full ./unittest/IlmCtl/IlmCtlTest 
valgrind -s --error-exitcode=1 --leak-check=full ./unittest/IlmCtlMath/IlmCtlMathTest 
valgrind -s --error-exitcode=1 --leak-check=full ./unittest/IlmImfCtl/IlmImfCtlTest
valgrind -s --error-exitcode=1 --leak-check=full ./unittest/IlmImfCtl/IlmImfCtlTest

#!/bin/sh
# set sh strict mode
set -o errexit
set -o nounset
IFS=$(printf '\n\t')

cd /home/scu/osparc_python_runner_tensorflow

echo "starting service as"
echo " User    : $(id "$(whoami)")"
echo " Workdir : $(pwd)"
echo "..."
echo

python main.py setup
/bin/sh main.sh
python main.py teardown
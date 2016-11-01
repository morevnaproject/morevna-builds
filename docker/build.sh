#!/bin/bash


SCRIPT_DIR=$(cd `dirname "$0"`; pwd)

${SCRIPT_DIR}/debian-7-64bit/build.sh
${SCRIPT_DIR}/debian-7-32bit/build.sh

#!/bin/bash
set -e

 # check for ruby and ruby gem "copyright-header"
if  [[ ( -z $(command -v ruby) ) || ( -z $(command -v copyright-header) ) ]]; then
   echo "Ruby and the copyright-header gem are required for this script, please install"
   exit 1
 fi

exit 0

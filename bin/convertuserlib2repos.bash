#!/bin/bash
# TEB 20150105
# Converts list of directories within userlib into repositories
# Uploads repositories to git server
#   repository is one of:
#   appdir: contributed application directories
#   bin: contributed binaries
#   fidlib: contributed FIDs
#   maclib: contributed macros
#   psglib: contributed pulse sequences
#   shapelib: contributed waveform shapes
#   templates: contributed templates
#   misc: miscellaneous contributions
set -o nounset
set -e

dirs=( appdir bin fidlib imaging maclib psglib shapelib templates wtlib misc )

echo "Directories: ${dirs[@]}"

for dir in ${dirs[@]}; do
  cd "${dir}" > /dev/null 2>&1 || {
    echo "Directory ${dir} could not be found! Skipping."
    continue
  }
  echo "Making a repo in ${dir}"
  /home/timburrow/Documents/Source/scripts/convert2onerepo.bash
  cd ..
done

exit 0

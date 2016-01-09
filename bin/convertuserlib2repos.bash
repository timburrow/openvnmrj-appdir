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
# From Stackoverflow http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
# Get the script diectory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  _SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
_SCRIPTDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo "Script running from ${_SCRIPTDIR}"


dirs=( appdir bin fidlib imaging maclib psglib shapelib templates wtlib misc )

echo "Directories: ${dirs[@]}"

for dir in ${dirs[@]}; do
  cd "${dir}" > /dev/null 2>&1 || {
    echo "Directory ${dir} could not be found! Skipping."
    continue
  }
  echo "Making a repo in ${dir}"
  "${_SCRIPTDIR}"/convert2onerepo.bash
  cd ..
done

exit 0

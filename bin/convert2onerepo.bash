#!/bin/bash

# convert2onerepo.bash - converts one directory within uselib 
# into a repository and pushed up to my NAS
#
# Copyright 2016 Tim Burrow
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# function that returns the description from a file passed as $1
set -o nounset
#set -e
function _description {
  local tdescription
gobble=0
while read -r line; do 
  if [ ${gobble} -eq 0 ]; then
    if [ $(expr "${line}" : "^Description:[ ].*$") -gt 0 ]; then 
        gobble=1
        tdescription=$(expr "${line}" : "^Description:[ ]*\(.*\)$") 
        echo "!${tdescription}"
        continue
    fi
  else
    if [ -z "${line}" ]; then ## empty line
        gobble=0
        continue
    else
#       echo "!${line}"
       tdescription+=" ";
       tdescription+=${line}
       continue
    fi
  fi
done < "$1"
description=$(echo "${tdescription}"| fmt -s -w 72)
}

function makereadme() {
cat > "${2}" <<EOF
#Userlib/${1}
This repository contains the userlib/${1} contributions for VnmrJ as packaged in VnmrJ 4.2

##NOTES & CAUTIONS
* Many of these contributions were incorporated into the core VnmrJ software years ago, so may be redundant with core capabilities
* Most of the contributions are obsolete.
* Though many contributions work, there is often a better way of doing things in the more modern software
* These contributions are not guaranteed to work
* These tools may work on some systems but not others. Many will only work with certain versions of VnmrJ, VNMR, RHEL, or Solaris.
* Use these tools at your own risk. Some of them, such as pulse sequences, could potentially damage hardware, and neither Agilent nor UO is responsible for such damage.
* Though this is the User Library, users' contributions are mixed with those from Varian and Agilent staff. On Spinsights, similar Agilent-provided materials like Chempack are available in Toolkit, and shared materials from users/customers are here in User Library. Agilent staff still do contribute to the currently active User Library, but, like all other contributions, those are personal materials that they have developed and find useful, and they are not officially supported by Agilent or guaranteed to work.
* The last update to this file was performed on February 1, 2013, and it will not be updated again.
* This initially should only contain contributions from Agilent and/or Varian but your contributions are welcome

##Downloading
You may download this repository from GitHub at:  
https://github.com/OpenVnmrJ/${1}.git

##Updating and adding
- Fork on GitHub
- Do not add your contribution to the master branch
- If updating contribution, checkout the tag of the contribution, update and commit on the contribution branch
- If adding a new contribution, checkout a new branch with the name of the contribution, push the new branch to your repository, add and commit on the new branch
- Tag your update of change with the name of the contribution, followed by a version, for example, mymacro-v1.1
- Push your branch to your fork; remember to push the tags too
- Make a pull request to the OpenVnmrJ repository

##Contributions

Below is a list of each contribution. To access a contributions, check out its tag

EOF
# End of README.md
# information about each contribution will be appended
}


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

# Get the current directory and path
_DIR=${PWD##*/}
_PATH=${PWD}

# check for ruby and ruby gem "copyright-header"
if  [[ ( -z $(command -v ruby) ) || ( -z $(command -v copyright-header) ) ]]; then
   echo "Ruby and the copyright-header gem are required for this script, please install"
   exit 1
fi

# check for readme.yml
if [ -f "${_SCRIPTDIR}/readme.yml" ]; then
  READMEYML="${_SCRIPTDIR}/readme.yml"
elif [ -f readme.yml ]; then
  READMEYML="readme.yml"
else
  TEMPREADMEYML=/tmp/readme.yml
  READMEYML="${TEMPREADMEYML}"
  cat > "${READMEYML}" <<EOFYML
readme:
  ext: ['.readme', '.README']
  comment:
    open:   '#\n'
    close:  '#\n'
    prefix: '# '

EOFYML
fi

# we need to run in a temporary directory as we'll be making new archive files
if [[ -d git-repo ]]; then
  rm -rf git-repo
fi

gitdir=git-repo/"${_DIR}"
mkdir -p "${gitdir}"
cd "${gitdir}"

if [[ -d .git ]]; then
  rm -rf .git
fi

_TAG=-v1.0
# sign commits and branches if possible
gitsignkey=$(git config --global --get user.signingkey)
git init
makereadme "${_DIR}" "${gitdir}"

# First pass; make top level READMEs and extract all files
contriblist=()
cd "${_PATH}"
for archive in *.tar.Z; do
  echo ": ${archive}"
  archivename=`basename ${archive} .tar.Z`
# check if Agilent contribution
  agilent=""
  varian=""
  agilent=$(grep -i submitter "${archivename}.README"| grep -i "varian\|agilent")
  yourname=$(grep -i "your name" "${archivename}.README"| grep -i "varian\|agilent")
  varian=$(grep -i company "${archivename}.README"| grep -i "varian\|agilent")
  if [[ -z ${agilent} && -z ${varian} && -z ${yourname} ]]; then
    echo "#### Skipping non-Agilent ${archivename}"
    grep -i "submitter\|company" "${archivename}.README"
    continue
  fi
  contriblist+=(${archivename})
  description=""
  _description "${archivename}.README"
  tail -n +5 "${archivename}.README" | head -n -11 - > "${archivename}.tmp"
  # this is archivename.README, not markdown 
  cat >> "${archivename}.tmp" <<-EOF1

** This software has not been tested on OpenVnmrJ. Use at your own risk. **

To install this user contribution:  
Download the repository from GitHub and checkout the tag of the contribution you want.
Typically tags end in the version (e.g. ${_TAG})

     git clone https://github.com/OpenVnmrJ/${_DIR}  
     cd ${_DIR}  
     git checkout ${archivename}${_TAG}


You may also make a new branch and cherry-pick the multiple tags:  

     git checkout -b mybranch
     git cherry-pick  ${archivename}${_TAG}

then read ${archivename}.README   

In most cases, use extract to install the contribution:  

    extract ${_DIR}/${archivename}

EOF1
# Clean up address, phone, etc
  cat "${archivename}.tmp" | grep -i -v "Address:"| grep -i -v "Phone:" | grep -i -v "FAX:" | \
  grep -i -v "Company/University:" | grep -i -v "email" | grep -i -v "e-mail"> "${gitdir}"/"${archivename}.README"
  rm "${archivename}.tmp"
  copyright-header --add-path "${gitdir}"/"${archivename}.README" \
  --syntax "${READMEYML}" --license ASL2 --copyright-holder "University of Oregon" --copyright-software "${archivename}" \
  --output-dir . \
  --copyright-software-description "${description}" \
  --word-wrap 75 --copyright-year 2016

# This is in markdown
  cat  >> "${gitdir}"/README.md <<-EOF2
##${archivename} 
>${description}

---
To install the contribution, checkout the tag ${archivename}${_TAG}:  
```
    git checkout ${archivename}${_TAG}  
```
then read ${archivename}.README   

Usually use extract to install the contribution:  
```
    extract ${_DIR}/${archivename}
```
EOF2

done
# make sure we are at the top of the repo
cd "${_PATH}"/"${gitdir}"
# word wrap at 76 characters
fmt -s -w 76 README.md > README.tmp
mv README.tmp README.md

# cleanup readme.yml
if [[ ! -z "${TEMPREADMEYML:-}" ]]; then
  rm "${TEMPREADMEYML}"
fi

# done creating all files, now in master, add README.md and commit
  git add README.md
if [[ -z "${gitsignkey}" ]]; then
  git commit -m "Initial commit with README"
else
  git commit -S -m "Initial commit with README"
fi
git remote add origin "ssh://git@github.com:22/OpenVnmrJ/${_DIR}.git"
git pull --rebase origin master
git fetch --all

gitversion=$( git --version | sed 's/.* //g' )
gitversionA=(${gitversion//./ })
echo "Git version array is ${versionA[@]} minor version is ${versionA[2]}"
gitvmajor=${gitversionA[0]}
gitvminor=${gitversionA[1]}
gitvincrement=${gitversionA[2]}

# orphan was introduced in git 1.7.2, CentOS 6 ships with 1.7.1
if [[ (( ${gitvmajor} < 2 )) && (( ${gitvminor} < 8 )) && (( ${gitvincrement} < 2 )) ]]; then
  gitcheckout="-b"
else
  gitcheckout="--orphan"
fi

# Second pass; adding all branches and tags
if [[ ! -z ${contriblist:-} ]]; then
echo "All files: ${contriblist[@]}"
cd "${_PATH}"/"${gitdir}"
for archivename in ${contriblist[@]}; do
  echo "> ${archivename}"
#  archivename=`basename ${archive} .tar.Z`
  description=""
  _description "${_PATH}"/"${archivename}.README"
# TEB: add files so changes can be tracked in git
  git checkout ${gitcheckout} "${archivename}"
  tar zxf "${_PATH}"/"${archivename}".tar.Z
  files=$(tar ztf "${_PATH}"/"${archivename}".tar.Z)
  git add ${files[@]}
  if [[ -z "${gitsignkey}" ]]; then
    git commit -m "${archivename} v1.0 " -m "${description}"
    git tag -a "${archivename}${_TAG}" -m "${description}" 
  else
    git commit -S -m "${archivename} v1.0 " -m "${description}"
    git tag -s "${archivename}${_TAG}" -m "${description}" 
  fi
  git checkout master
done
fi
#git remote add origin git@github.com:timburrow/maclib.git
#git push -u origin --all
#git push -u origin --tags
#~/Documents/Source/scripts/makenasrepo.bash
git push --set-upstream origin master
git push origin --all
git push origin --tags
git remote -v
git branch -a

exit 0


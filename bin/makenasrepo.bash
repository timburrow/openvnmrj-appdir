#!/bin/bash
#
# makenasrepo.bash -
# 
# TEB 20151224 Makes an empty repository on the NAS server 
# Push an exisiting repo using git push nas --all
#
# Copyright 2015-2016 Tim Burrow
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
#
# If Argument, switch to that directory
# If no argument, assume we are in git repo already
if [ -n "$1" ]
  then
    echo "Changing working directory to $1"  
    cd "$1"
fi
# Check if .git exists
if ! [ -d .git ]; then
  echo "No git repository found!"
  exit 85
fi

directory="${PWD##*/}"
echo "Making repository $directory on the NAS"
reponame="${directory}.git"
nasip=192.168.2.28
nasadmin="root"
nasuser="gittim" # owner of the repos
nasgitdir="/volume1/git_repos"
echo "$nasadmin@$nasip cd $nasgitdir && mkdir $reponame && cd $reponame && git init --bare && cd .. && chown -R $nasuser:users $reponame"
ssh "$nasadmin@$nasip" "cd $nasgitdir && mkdir $reponame && cd $reponame && git init --bare && cd .. && chown -R $nasuser:users $reponame"

# ssh://gittim@192.168.2.28:/volume1/git_repos/maclib.git
git remote add nas "ssh://$nasuser@$nasip:$nasgitdir/$reponame"
git push nas --all
git push nas --tags
git push --set-upstream nas master
git remote -v
git branch -av
exit 0

#!/bin/bash
# checks git version
version=$( git --version | sed 's/.* //g' )
versionA=(${version//./ })
versionshort=${version%.*}
echo "Git version is ${version} and short number is ${versionshort}"
echo "Git version array is ${versionA[@]} minor version is ${versionA[2]}"
result=$( echo "${versionshort} > 1.9" | bc )
if (( ${result} == 1 )); then
  echo "Version is > 1.9"
else 
  echo "Version is <= 1.9"
fi

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

echo ${gitcheckout}

exit 0


#!/bin/bash
# tests fmt
#
in="Analogon to the array macro, but for entering exponential parameter arrays. Similar to \"array\" - now a standard VNMR / VnmrJ macro), \"xarray\" can be called without argument or by just giving a parameter name as single argument, invoking an interactive mode; typically, however, the macro will be used with four arguments: xarray<('parametername'<,#steps,start,finalvalue>)> Note that unlike with \"array\", the last argument is NOT a stepsize (or rather multiplier), but the size of the last array element; the multiplier will be calculated by \"xarray\". Example: xarray('nt',10,2,1024) results in nt=2,4,8,16,32,64,128,256,512,1024 and xarray('d2',8,0.1,10) defines an array d2=.1,.19307,.372759,.719686,1.3895,2.6827,5.17947,10 This macro has been recovered from an earlier package contribution by the author, \"packages.51/extendo"

echo "${in}"

out=$(echo "${in}"| fmt -s -w 72)

echo "${out}"

exit 0


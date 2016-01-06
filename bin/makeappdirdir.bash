#!/bin/bash
# Makes an directory to store appdirs in /home/appdir
# owned by vnmr1:nmr
# Assumes vnmrj is installed

osType=`vnmr_uname`
if [ x${osType} = "xLinux" ]; then
  appdirdir=/home/appdirs
elif [ x${osType} = "xDarwin" ]; then
  appdirdir=/Users/Shared/appdirs
elif [ x${osType} = "xSolaris" ]; then
  appdirdir=/export/home/appdirs
fi

sudo=/usr/bin/sudo

if [ ! -d "${appdirdir}" ]; then
  "${sudo}" mkdir "${appdirdir}"
  "${sudo}" chown -R vnmr1:nmr "${appdirdir}"
  "${sudo}" chmod 755 "${appdirdir}"
  cat << EOF
New directory for appdirs created at ${appdirdir}.
* Copy or move your appdir into ${appdirdir} 
* Add your appdir to your application directory tree in VnmrJ
* Activate your appdir within VnmrJ to use it

EOF

fi

exit 0

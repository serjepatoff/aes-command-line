#!/bin/sh

CIPHER="aes-256-cbc"
SCRIPT=`basename $0`
SCRIPT=${SCRIPT%.sh}
SRM_CMD=srm

command -v openssl >/dev/null 2>&1 || { echo "Could not find openssl in path"; exit 1; }
command -v $SRM_CMD >/dev/null 2>&1 || SRM=shred;
command -v $SRM_CMD >/dev/null 2>&1 || { echo "Could not find 'srm' or 'shred' for secure deletion"; exit 1; }


if [ $# -ne 1 ]
then
  echo "Usage: $0 <file>"
  exit 1
fi

if test -r "$1" -a -f "$1"
then
  cd `dirname $1`

  if [ "$SCRIPT" = "aes-encrypt" ]
  then

    openssl $CIPHER -salt -in $1 -out $1.aes
    if [ $? -eq 0 ]
    then
      echo "- created $1.aes in $(pwd)"
      echo "- securely deleting using $SRM_CMD"
      $SRM_CMD $1
      echo "- original file $1 deleted"
    else
      echo "- encryption failed, file is still there"
    fi

  else

    out=${1%.aes}
    if [ "$1" != "$out.aes" ]
    then
        echo "- $SCRIPT argument should contain .aes extension"
        exit 1
    fi
      
    openssl $CIPHER -salt -d -in $1 -out $out
    if [ $? -eq 0 ]
    then
      echo "- decrypted $out in $(pwd)"
      rm $1
      echo "- deleted $1"
    fi

  fi


else
  echo "- file $1 does not exists"
  exit 1
fi

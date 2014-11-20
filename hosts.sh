#!/bin/bash
SCRIPTDIR=/Users/patrick/sh/add-host
BASEPATH=$SCRIPTDIR

source "$BASEPATH/inc/functions.sh"
eval $(parse_yaml $BASEPATH/config/config.yml)

filename=
dir=
add=
remove=

while [ "$1" != "" ]; do
  case $1 in
      add | a)                add=1
                              ;;
      remove | rm | delete)   remove=1
                              ;;
      -f | --file )           shift
                              filename=$1
                              echo "using $filename"
                              ;;
      ls | l )                ls $BASEPATH/sites/
                              exit
                              ;;
      ports )                 more $BASEPATH/ports
                              exit
                              ;;
      -h | --help)            usage_hosts
                              exit
                              ;;
      . )
        if [ "$add" != "" ]
        then
         src=`pwd`
        fi
        ;;
      * )
        if [ "$remove" != "" ]
        then
          filename=$1
        fi
        ;;
  esac
  shift
done

if [ $add != "" ]
then
  opts=
  if [ "$filename" != "" ]
  then
    opts="-f $filename"
  else
    if [ "$src" == "" ]
    then
      src=`pwd`
    fi
  fi
  if [ "$src" != "" ]
  then
    opts="-d $src"
  fi
  echo "running command $BASEPATH/add-hosts.sh $opts"
  exit
  $BASEPATH/add-host.sh $opts
fi

if [ $remove != "" ]
then
  $BASEPATH/remove-host.sh
fi

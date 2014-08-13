#!/bin/bash
source 'inc/functions.sh'

eval $(parse_yaml config/config.yml)

while getopts ":f:" opt; do
  case $opt in
    f)
      echo "-f was triggered, Parameter: $OPTARG" >&2
      eval $(parse_yaml $OPTARG)
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ -z "$host" ]; then
  printf "Enter Hostname: "
  read host
fi
if [ -z "$apache" ]; then
  printf "Apache [yes/no]?: "
  read apache
fi
if [ -z "$src" ]; then
  printf "Name of source directory (case senseative): "
  read src
fi

echo $host

echo "Removing host..."

BASEPATH=${PWD}
SUCCESS=0

if [ "$apache" = "yes" ] || [ "$apache" = "y" ]; then
  echo "Removing apache config files..."

  APACHE_CONFIG_FILE=$BASEPATH/src/apache.vhost
  APACHE_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.apache
  APACHE_TEMP_CONFIG_FILE=$BASEPATH/temp/apache.temp

  if [ -e $apache_NEW_CONFIG_FILE ]
  then
    rm $apache_NEW_CONFIG_FILE
  fi

  NGINX_CONFIG_FILE=$BASEPATH/src/nginx.apache
  NGINX_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
  NGINX_TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.apache

  if [ -e $NGINX_NEW_CONFIG_FILE ]
  then
    rm $NGINX_NEW_CONFIG_FILE
  fi

  if [ -e $apache_BASEPATH/sites-enabled/$host ]; then
    sudo rm $apache_BASEPATH/sites-enabled/$host
  fi

  if [ -h $NGINX_BASEPATH/sites-enabled/$host ]; then
    rm $NGINX_BASEPATH/sites-enabled/$host
  fi

  if [ $SRCDIR ]; then
    if [ -h $apache_SRCPATH/$host ]; then
      echo "Omitting link to apache source files"
    else
      ln -s $src/$SRCDIR $apache_SRCPATH/$host
    fi
  fi


else
  echo "Removing config file for passenger server."
  CONFIG_FILE=$BASEPATH/src/nginx.other
  NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
  TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.other
  if [ -e $NEW_CONFIG_FILE ]
  then
    rm $NEW_CONFIG_FILE
  fi

  echo $NGINX_BASEPATH/sites-enabled/$host
  if [ -h $NGINX_BASEPATH/sites-enabled/$host ]; then
    echo "Removing nginx link"
    rm $NGINX_BASEPATH/sites-enabled/$host
  else
    echo "nginx link already deleted."
  fi
fi

if [ $SRCDIR ]; then
  if [ -d $NGINX_SRCPATH/$host ]; then
    echo "Omitting link to nginx source files"
  else
    ln -s $src/$SRCDIR $NGINX_SRCPATH/$host
  fi
fi

grep -q "$host" /etc/hosts

if [ $? -eq $SUCCESS ]
then
  echo "Removing from hosts file."
  cp /etc/hosts $BASEPATH/temp/hosts.backup
  sed "/$host/d" /etc/hosts > $BASEPATH/temp/hosts
  sudo mv $BASEPATH/temp/hosts /etc/hosts
fi

grep -q "$host" ports

if [ $? -eq $SUCCESS ]
then
  echo "Removing from ports file."
  sed "/$host/d" ports > $BASEPATH/temp/ports
  rm ports
  mv $BASEPATH/temp/ports ports
fi

sudo apachectl restart && sudo nginx -s stop && sudo nginx;

echo "complete!"

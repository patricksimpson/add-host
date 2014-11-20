#!/bin/bash
SCRIPTDIR=/Users/patrick/sh/add-host
BASEPATH=$SCRIPTDIR
SUCCESS=0

source "$BASEPATH/inc/functions.sh"
eval $(parse_yaml $BASEPATH/config/config.yml)

function usage
{
      echo "usage: addhost [[[-f configfile ] [-d /path/to/source/files]]]"
}

filename=
dir=

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )           shift
                                filename=$1
                                echo "using $filename"
                                ;;
        -d | --dir)             shift
                                src=$1
                                echo "using $src"
                                ;;
        . )                     src=`pwd`
                                echo "using $src"
                                ;;
        -h | --help)           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ "$filename" != "" ]; then
  echo "-f was triggered, Parameter: $filename" >&2
  eval $(parse_yaml $filename)
fi

if [ -z "$host" ]; then
  printf "Enter Hostname (example.dev): "
  read host
fi

if [ -z "$apache" ]; then
  printf "Apache [yes/no]?: "
  read apache
fi

if [ "$apache" == "y" ] || [ "$apache" == "yes" ]; then
  port=8080
fi

if [ -z "$port" ]; then
  printf "Port (press enter for static): "
  read port
fi

if [ -z "$port" ]; then
  port=80
fi

if [ -z "$src" ]; then
  printf "Full path to source directory (case senseative): "
  read src
else
  echo "Using source directory '$src'"
fi

echo ""
echo "host: $host"
echo "port: $port"
echo "apache: $apache"
echo "src: $src"
echo ""

echo "Creating YML config file for future reference."
echo "host: $host" > $BASEPATH/sites/$host.yml
echo "port: $port" >> $BASEPATH/sites/$host.yml
echo "apache: $apache" >> $BASEPATH/sites/$host.yml
echo "src: $src" >> $BASEPATH/sites/$host.yml

echo $BASEPATH/sites/$host.yml
echo ""

SUCCESS=0

if [ "$apache" = "yes" ] || [ "$apache" = "y" ]; then
  echo "Creating apache config files..."

  APACHE_CONFIG_FILE=$BASEPATH/config/apache.vhost
  APACHE_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.apache
  APACHE_TEMP_CONFIG_FILE=$BASEPATH/temp/apache.temp

  if [ -e $APACHE_NEW_CONFIG_FILE ]
  then
    rm $APACHE_NEW_CONFIG_FILE
  fi

  sed "s/HOSTNAME/$host/" $APACHE_CONFIG_FILE > $APACHE_TEMP_CONFIG_FILE && mv $APACHE_TEMP_CONFIG_FILE $APACHE_NEW_CONFIG_FILE
  sed "s/PORT/$port/" $APACHE_NEW_CONFIG_FILE > $APACHE_TEMP_CONFIG_FILE && mv $APACHE_TEMP_CONFIG_FILE $APACHE_NEW_CONFIG_FILE

  NGINX_CONFIG_FILE=$BASEPATH/config/nginx.apache
  NGINX_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
  NGINX_TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.apache

  if [ -e $NGINX_NEW_CONFIG_FILE ]
  then
    rm $NGINX_NEW_CONFIG_FILE
  fi

  sed "s/HOSTNAME/$host/g" $NGINX_CONFIG_FILE > $NGINX_TEMP_CONFIG_FILE && mv $NGINX_TEMP_CONFIG_FILE $NGINX_NEW_CONFIG_FILE
  sed "s/PORT/$port/g" $NGINX_NEW_CONFIG_FILE > $NGINX_TEMP_CONFIG_FILE && mv $NGINX_TEMP_CONFIG_FILE $NGINX_NEW_CONFIG_FILE

  if [ -h $APACHE_BASEPATH/sites-enabled/$host ]; then
    echo "Omitting link to apache config."
  else
    sudo ln -s $APACHE_NEW_CONFIG_FILE /etc/apache2/sites-enabled/$host
  fi

  if [ -h $NGINX_BASEPATH/sites-enabled/$host ]; then
    echo "Omitting link to nginx config."
  else
    ln -s $NGINX_NEW_CONFIG_FILE $NGINX_BASEPATH/sites-enabled/$host
  fi

  if [ $src]; then
    if [ -h $APACHE_SRCPATH/$host ]; then
      echo "Omitting link to apache source files"
    else
      ln -s $src $APACHE_SRCPATH/$host
    fi
  fi

  if [ -e $APACHE_TEMP_CONFIG_FILE ]
  then
    rm $APACHE_TEMP_CONFIG_FILE
  fi

  if [ -e $NGINX_TEMP_CONFIG_FILE ]
  then
    rm $NGINX_TEMP_CONFIG_FILE
  fi

else
  if [ $port == 80 ]; then
    echo "Creating static webserver"
    CONFIG_FILE=$BASEPATH/config/nginx.static
    NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
    TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.static
  else
    echo "Creating config file for passenger server"
    CONFIG_FILE=$BASEPATH/config/nginx.other
    NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
    TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.other
  fi
  if [ -e $NEW_CONFIG_FILE ]
  then
    rm $NEW_CONFIG_FILE
  fi

  sed "s/HOSTNAME/$host/g" $CONFIG_FILE > $TEMP_CONFIG_FILE && mv $TEMP_CONFIG_FILE $NEW_CONFIG_FILE
  sed "s/PORT/$port/g" $NEW_CONFIG_FILE > $TEMP_CONFIG_FILE && mv $TEMP_CONFIG_FILE $NEW_CONFIG_FILE

  if [ -e $NGINX_BASEPATH/sites-enabled/$host ]; then
    echo "Omitting link to nginx config."
  else
    ln -s $NEW_CONFIG_FILE $NGINX_BASEPATH/sites-enabled/$host
  fi

  if [ -e $TEMP_CONFIG_FILE ]
  then
    rm $TEMP_CONFIG_FILE
  fi

fi

if [ $src ]; then
  if [ -d $NGINX_SRCPATH/$host ]; then
    echo "Omitting link to nginx source files"
  else
    ln -s $src $NGINX_SRCPATH/$host
  fi
fi

grep -q "$host" /etc/hosts

if [ $? -eq $SUCCESS ]
then
  echo "Omitting append to hosts file."
else
  echo "Appending $host to hosts file."
  echo "127.0.0.1 $host" | sudo tee -a /etc/hosts
fi

sudo apachectl restart && sudo nginx -s stop && sudo nginx;

echo "$host $port" >> $BASEPATH/ports

echo "complete!"



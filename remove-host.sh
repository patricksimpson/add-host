#enabled!/bin/bash
SCRIPTDIR=/Users/patrick/sh/add-host
BASEPATH=$SCRIPTDIR
SUCCESS=0

source "$BASEPATH/inc/functions.sh"

eval $(parse_yaml $BASEPATH/config/config.yml)

filename=
dir=

while [ "$1" != "" ]; do
    case $1 in
        -f | --file )           shift
                                filename=$1
                                echo "using $filename"
                                ;;
        ls | l )                ls $BASEPATH/sites/
                                exit
                                ;;
        -h | --help)            usage_remove
                                exit
                                ;;
        * )                     filename=$1
                                ;;
    esac
    shift
done

if [ "$filename" != "" ]; then
  othername=`ls $BASEPATH/sites/ | grep $filename`
  if [ -f "$BASEPATH/sites/$othername" ]; then
    filename=$othername
    echo "-f was triggered, Parameter: $BASEPATH/sites/$filename" >&2
  else
    echo $othername
    echo "Matched many hosts, continue."
  fi
fi

cd $BASEPATH/sites
printf "Enter the config file (tab to complete): "
read -e othername
filename=$othername
if [ -f $BASEPATH/sites/$filename ]; then
  echo "Using $BASEPATH/sites/$filename"
else
  echo "No host file found!"
  exit
fi
eval $(parse_yaml $BASEPATH/sites/$filename)

if [ -z "$host" ]; then
  printf "Enter Hostname (example.dev): "
  read host
fi

if [ -z "$apache" ]; then
  printf "Apache (yes/no)?: "
  read apache
fi

if [ "$apache" == "y" ] || [ "$apache" == "yes" ]; then
  port=$APACHE_PORT
fi

if [ -z "$port" ]; then
  printf "Port (Enter for static): "
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

echo "Removing host..."

if [ "$apache" = "yes" ] || [ "$apache" = "y" ]; then
  echo "Removing apache config files..."

  APACHE_CONFIG_FILE=$BASEPATH/src/apache.vhost
  APACHE_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.apache
  APACHE_TEMP_CONFIG_FILE=$BASEPATH/temp/apache.temp

  if [ -e $APACHE_NEW_CONFIG_FILE ]
  then
    echo "delete $APACHE_NEW_CONFIG_FILE"
    rm $APACHE_NEW_CONFIG_FILE
  fi

  NGINX_CONFIG_FILE=$BASEPATH/src/nginx.apache
  NGINX_NEW_CONFIG_FILE=$BASEPATH/hosts/$host.nginx
  NGINX_TEMP_CONFIG_FILE=$BASEPATH/temp/nginx.apache

  if [ -e $NGINX_NEW_CONFIG_FILE ]
  then
    echo "delete $NGINX_NEW_CONFIG_FILE"
    rm $NGINX_NEW_CONFIG_FILE
  fi

  if [ -h $APACHE_BASEPATH/sites-enabled/$host ]; then
    echo "delete $APACHE_BASEPATH/sites-enabled/$host"
    sudo rm $APACHE_BASEPATH/sites-enabled/$host
  fi

  if [ -h $NGINX_BASEPATH/sites-enabled/$host ]; then
    echo "delete $NGINX_BASEPATH/sites-enabled/$host"
    rm $NGINX_BASEPATH/sites-enabled/$host
  fi

  if [ $SRCPATH ]; then
    if [ -h $APACHE_SRCPATH/$host ]; then
      echo "delete $APACHE_SRCPATH/$host"
      rm $APACHE_SRCPATH/$host
    else
      echo "Omitting: apache source files link already deleted."
      echo "Omitted: rm $APACHE_SRCPATH/$host"
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
    echo "Omitting: nginx link already deleted."
  fi
fi

if [ $SRCPATH ]; then
  if [ -h $NGINX_SRCPATH/$host ]; then
    rm $NGINX_SRCPATH/$host
  else
    echo "Omitting: link to nginx source files already deleted."
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

grep -q "$host" $BASEPATH/ports

if [ $? -eq $SUCCESS ]
then
  echo "Removing from ports file."
  sed "/$host/d" $BASEPATH/ports > $BASEPATH/temp/ports
  rm $BASEPATH/ports
  mv $BASEPATH/temp/ports $BASEPATH/ports
fi

sudo apachectl restart && sudo nginx -s stop && sudo nginx;

echo "$host removed!"

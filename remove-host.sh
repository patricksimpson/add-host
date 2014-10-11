#enabled!/bin/bash
SCRIPTDIR=/Users/patrick/shellscripts/add-host
BASEPATH=$SCRIPTDIR
SUCCESS=0

source "$BASEPATH/inc/functions.sh"

eval $(parse_yaml $BASEPATH/config/config.yml)

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

echo "complete!"

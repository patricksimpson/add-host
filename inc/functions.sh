#/bin/bash

function usage
{
      echo "usage: addhost [[[-f configfile ] [-d /path/to/source/files]]]"
}

function usage_remove
{
      echo "usage: removehost [[[-f host ] [ls | l ]]]"
}

function usage_hosts
{
      echo "usage: hosts [[add | a | remove | rm] [-f | --file] [ ports ] [ ls | l ]]"
      echo "add | a       Invoke the add-host command"
      echo "remove | rm   Invoke the remove-host command"
      echo "-f --file     The configuration file, in $BASEPATH/sites"
      echo "ports         Lists the currently used ports per hostname"
      echo "ls | l        Lists the hosts configuration files"
}
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

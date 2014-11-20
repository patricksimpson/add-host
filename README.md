add-host
========

A shell script to add to nginx/apache and hosts


# Install

    chmod +x add-host.sh
    chmod +x remove-host.sh
    chmod +x hosts.sh

## !important;
Change your configuration files to match your system specifications:

Example:
    
    # Where your apache source files are located.
    APACHE_SRCPATH: /Users/[yourusername]/src/www
    
    # NGINX source files.
    NGINX_SRCPATH: /var/www
    
    # Your apache config files.
    APACHE_BASEPATH: /etc/apache2
    
    # Your NGINX config files.
    NGINX_BASEPATH: /etc/nginx
    
    # Your default apache port.
    APACHE_PORT: 8080


# Running (basic)

    ./add-host.sh
    
Prompts for a local hostname, port, apache(yes/no), and source location (based on your configuration checkout)
    
## HIGHLY Recommended 

For the most effective way to add a host, add an alias to your bash/zsh alias file (e.g. `~/.aliases`) 

    addhost='/path/to/add-host/add-host.sh'
    removehost='/path/to/add-host/remove-host.sh'
    hosts='/path/to/add-host/hosts.sh'
    h='/path/to/add-host/hosts.sh'
    
*Note*: the command aliases ('addhost,removehost,hosts,h') can be whatever you'd like. Just don't use something you already have.
    
After you source your new aliases, you will be allowed to run the commnad from the directory of your chosing. 
    
This will allow you add a host inside the directory where you want to serve your files, such as

say you are currently in
    
    ~/mygithubs/coolproject
    
you can then run:

    addhost .

It will invoke the addhost command with that as the given source directory.

Also if you want to use the shorthand "hosts" runner script, run the following command inside your source directory:

    h add .

## Other Options:

    ./add-host.sh -f sites/example.dev.yml

## Removing host

    ./remove-host.sh

or
    
    ./remove-host.sh -f sites/example.dev.yml

A YML config file will be created for you in sites/

# Add a YML site

You can add a YML site config under sites/ before running add-host or remove-host

Format

    host: example.dev
    port: 3000
    apache: no
    src: example-src-files


## Hosts Helper

Included now is a hosts runner file. It will invoke the add-host or remove-host commands. 

    hosts --help

    usage: hosts [[add | a | remove | rm] [-f | --file] [ ports ] [ ls | l ]]
    add | a       Invoke the add-host command
    remove | rm   Invoke the remove-host command
    -f --file     The configuration file, in /Users/patrick/sh/add-host/sites
    ports         Lists the currently used ports per hostname
    ls | l        Lists the hosts configuration files

add-host
========

A shell script to add to nginx/apache and hosts


# Install

    chmod +x add-host.sh
    chmod +x remove-host.sh

## !important;
Change your configuration files to match your system specifications:

Example:

    # Source directory/path.
    SRCPATH: /Users/[yourusername]/github
    
    # Where your apache source files are located.
    APACHE_SRCPATH: /Users/[yourusername]/src/www
    
    # NGINX source files.
    NGINX_SRCPATH: /var/www
    
    # Your apache config files.
    APACHE_BASEPATH: /etc/apache2
    
    # Your NGINX config files.
    NGINX_BASEPATH: /etc/nginx


# Running

    ./add-host.sh

Prompts for a local hostname, port, apache(yes/no), and source location (based on your configuration checkout)

## Optional (preferred) run:

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

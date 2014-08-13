add-host
========

A shell script to add to nginx/apache and hosts


# Install

    chmod +x add-host.sh
    chmod +x remove-host.sh

## !important;
Change your configuration files to match your system specifications


# Running

    ./add-host.sh

Prompts for a local hostname, port, apache(yes/no), and source location (based on your configuration checkout)

A YML config file will be created for you in sites/

# Add a YML site

You can add a YML site config under sites/ before running add-host or remove-host

Format

    host: example.dev
    port: 3000
    apache: no
    src: example-src-files

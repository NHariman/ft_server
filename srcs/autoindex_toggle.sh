#!/bin/sh
echo -n "Welcome! Would you like to turn autoindex on or off? 1: on, 0: off.\nPlease indicate 1 or 0 and press[ENTER] to exit, type nvm:\n"
read INPUT

if [ $INPUT == "1" ];
then
    sed -i "26s/autoindex.*/autoindex on;/g" /etc/nginx/sites-available/default &&\
    echo "Nginx autoindex has been turned on.\nRestarting nginx:\n" &&\
    service nginx restart
elif [ $INPUT == "0" ];
then
    sed -i "26s/autoindex.*/autoindex off;/g" /etc/nginx/sites-available/default &&\
    echo "Nginx autoindex has been turned off.\nRestarting nginx:\n" &&\
    service nginx restart
elif [ $INPUT == "nvm" ];
then
    echo "Ok, bye!"
else
    echo "Please specify if autoindex needs to be turned on or off by calling the script and adding \"1\" for on or \"0\" for off to the end.\n"
fi
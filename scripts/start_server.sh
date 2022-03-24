#!/bin/bash
# Since our application will be stored in /var/www/django
# We want to CD into that directory
cd /var/www/django
# We are going to use gunicorn to run the Django app
# and bind it to port 9000
gunicorn --bind 0.0.0.0:9000 demo.wsgi > /dev/null 2> /dev/null < /dev/null &
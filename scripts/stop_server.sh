#!/bin/bash
# To stop the server, we are going to kill
# every process that contains the term
# gunicorn
pkill -f gunicorn
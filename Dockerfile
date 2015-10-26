# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from phusion/baseimage

maintainer cptfinch

# run echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
run apt-get update
run apt-get install -y build-essential git
run apt-get install -y python python-dev python-setuptools
run apt-get install -y nginx supervisor
run easy_install pip

# install uwsgi now because it takes a little while
run pip install uwsgi

# install nginx
run apt-get install -y python-software-properties
run apt-get update
RUN add-apt-repository -y ppa:nginx/stable
run apt-get install -y sqlite3

# install some dependencies of qatrack+
run apt-get install build-essential gfortran
run apt-get install python-dev
run apt-get install libatlas-dev libatlas-base-dev liblapack-dev
run apt-get install libpng12-dev libfreetype6 libfreetype6-dev
run apt-get build-dep python-matplotlib

# install our code
add . /home/docker/code/

# setup all the configfiles
run echo "daemon off;" >> /etc/nginx/nginx.conf
run rm /etc/nginx/sites-enabled/default
run ln -s /home/docker/code/nginx-app.conf /etc/nginx/sites-enabled/
run ln -s /home/docker/code/supervisor-app.conf /etc/supervisor/conf.d/

# run pip install
# run pip install -r /home/docker/code/app/requirements.txt
run pip install -r /home/docker/code/app/base.txt
run pip install -r /home/docker/code/app/optional.txt


run cd /home/docker/code/app/
run git init
run git remote add origin https://cptfinch@bitbucket.org/cptfinch/qatrackplus.git
run git pull origin master


# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
# run django-admin.py startproject website /home/docker/code/app/ 

run git clone https://cptfinch@bitbucket.org/cptfinch/qatrackplus.git /home/docker/code/app

expose 80
cmd ["supervisord", "-n"]

#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyBookProject using template book"
cd ~/hyla
hyla new --t book -d MyBookProject

echo "Project created"
ls -la ~/hyla/MyBookProject

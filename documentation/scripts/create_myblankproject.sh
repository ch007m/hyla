#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyBlankProject"
hyla new -b ~/hyla/MyBlankProject

echo "Create a MyBlankProject using --force option"
hyla new -b ~/hyla/MyBlankProject --force

echo "Project created"
ls -la ~/hyla/MyBlankProject

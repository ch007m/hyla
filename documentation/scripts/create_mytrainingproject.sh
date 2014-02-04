#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyTrainingProject using template book"
cd ~/hyla
hyla new --t training -d MyTrainingProject

echo "Project created"
ls -la ~/hyla/MyTrainingProject

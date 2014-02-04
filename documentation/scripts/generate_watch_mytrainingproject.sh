#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyTrainingProject using template book"
cd ~/hyla
hyla new --t training -d MyTrainingProject

echo "Project created"
ls -la ~/hyla/MyTrainingProject

cd ~/hyla/MyTrainingProject
echo "Geerate content"
hyla generate

ls -la ~/hyla/MyTrainingProject/generate_content

echo "Watch content"
hyla watch -s ~/hyla/MyTrainingProject/ -d ~/hyla/MyTrainingProject/generated_content
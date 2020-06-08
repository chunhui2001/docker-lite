#!/bin/sh

echo 'node --verion'
node --version 

echo 'npm --verion'
npm --version

echo 'gulp --verion'
gulp --version  

cd /app/work && npm i && npm i -S gulp-sourcemaps && gulp compress

ls -alh

#while true; do echo 1 >/dev/null 2>/dev/null; sleep 1; done
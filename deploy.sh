#!/bin/bash

# config vars
root_path="~/_Dev/10sheet/10sheet/"
maven_profile="local-slava"
maven_skip_tests="true"
maven_additional="-o" # by default - make it offline
# 

version="0.1"

if [ $# -gt 0 ]; then
	command=$1

	if [[ $command == "build" ]]; then
		build=`mvn clean package -P$maven_profile -Dmaven.test.skip=$maven_skip_tests $maven_additional`
		#echo "Build is done"
		echo $build
	fi

else
	echo "Usage: ./deploy.sh [command]

Description:
    Tomcat deploy tool

Required:
	Apache Maven
	Lessc compiler (optional)

Commands: 
    version - print current version
	"
fi
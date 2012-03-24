#!/bin/bash

### config vars

# root path for project, MUST HAS NOT trailing slash
root_path="~/_Dev/10sheet/10sheet"

# list of paths with static files; from root_path
static_path[0]="src/main/webapp/templates"
static_path[1]="src/main/webapp/templates"
static_path[2]="src/main/webapp/templates"
static_path[3]="src/main/webapp/templates"
static_path[4]="src/main/webapp/templates"

# path for Apache Tomcat root directory, MUST HAS NOT trailing slash
tomcat_path="/Library/Tomcat"

# name of application
tomcat_app="ROOT"

# "true" - Tomcat will be stopped by killing the process, recommended for local work
# "false" - Tomcat will be stopped by /bin/shutdown.sh script, recommended for production env
tomcat_hard_stop="true"

# Maven profile for building
maven_profile="local-slava"

# Maven can skip tests
maven_skip_tests="true"

# additional options for Maven
maven_additional="-o" # by default - make it offline

###

VERSION="0.1"
LESS_COMPRESSOR=`which lessc`

build() {
	build=`mvn clean package -P$maven_profile -Dmaven.test.skip=$maven_skip_tests $maven_additional`
	# TODO: check for BUILD ERROR/SUCCESSFUL strings
	echo "$build"
}

war() {
	echo $1
}

less() {
	echo $1
}

static() {
	echo $1
}

tomcat() {
	case $1 
	in
		"start")
			echo "Tomcat is starting..."
			result=`sh $tomcat_path/bin/startup.sh`
	    ;; 

		"stop")   
			# TODO: use tomcat_hard_stop
			echo "Tomcat is stopping..."
			result=`sh $tomcat_path/bin/shutdown.sh`
	    ;; 

		"restart")
	        result_stop=$(tomcat stop)
	        result_start=$(tomcat start)
	        result="$result_stop
$result_start"
	    ;; 
	esac 

	echo "$result"
}
 
help() {
	help="Usage: ./deploy.sh [command]

Description:
    Deployment (and not only...) tool for work in Apache Tomcat + Maven + ... + Less environment

Required:
    Apache Tomcat 6+
    Apache Maven 2+
    Lessc compiler (optional)

Commands:
    help                        - this page
    version                     - print current version
    build                       - Maven package build
    war                         - copy current WAR package to Tomcat
    less                        - compile css files from Less
    static                      - copy current static files to Tomcat
    tomcat [start|stop|restart] - Tomcat management
    test [test profile] [name]  - run test with specified profile and class name with Maven
    full                        - 'less' + 'build' + 'war' commands coherently
    full-static                 - 'less' + 'static' commands coherently
	"
	echo "$help"
}

if [ $# -gt 0 ]; then
	command=$1

    case $command
    in
    	"help") 
			echo "`help`"
		;;

    	"version") 
			echo $VERSION
		;;

		"build")
			build=`build`
			#echo "Build is done"
			echo "$build"
		;;

		"war")
			echo $VERSION
		;;

		"less")
			echo $VERSION
		;;

		"static")
			echo $VERSION
		;;

		"tomcat")
			if [ $# != 2 ]; then
				echo "`help`"
			else
				echo "$(tomcat $2)"
			fi
		;;

		"test")
			echo $VERSION
		;;				

		"full")
			echo $VERSION
		;;

		"full-static")
			echo $VERSION
		;;								
    esac

else
	echo "`help`"
fi
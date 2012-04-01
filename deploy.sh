#!/bin/bash

### config vars

# root path for project, MUST HAS NOT trailing slash
root_path="$HOME/_Dev/10sheet/10sheet"

# list of paths with static files; from root_path
static_path[0]="src/main/webapp/templates"
static_path[1]="src/main/webapp/js"
static_path[2]="src/main/webapp/css"
static_path[3]="src/main/webapp/tpl"
static_path[4]="src/main/webapp/main"

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
	build=`cd $root_path && mvn clean package -P$maven_profile -Dmaven.test.skip=$maven_skip_tests $maven_additional`
	# TODO: check for BUILD ERROR/SUCCESSFUL strings
	echo "$build"
}

war() {
	result=`cd $root_path/target &&
			sudo rm -f $tomcat_path/webapps/$tomcat_app.war && 
			sudo rm -rf $tomcat_path/webapps/$tomcat_app && 
			cp $tomcat_app.war $tomcat_path/webapps/$tomcat_app.war`
	echo "WAR was copied"
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
			echo "Tomcat is stopping..."

			if [ $tomcat_hard_stop == "true" ]; then
				CPID=`ps -axe | grep Tomcat | grep java | awk '{print $1}'`
				if [[ "$CPID" != "" && "$CPID" -ge 0 ]]; then
					sudo kill -9 $CPID
					result="Killed procces: $CPID"
				else
					result="Tomcat was not started"
				fi
			else
				result=`sh $tomcat_path/bin/shutdown.sh`
			fi
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
			echo "$build"
		;;

		"war")
			echo "$(war)"
		;;

		"less")
			# TODO
			echo "`help`"
		;;

		"static")
			# TODO
			echo "`help`"
		;;

		"tomcat")
			if [ $# != 2 ]; then
				echo "`help`"
			else
				echo "$(tomcat $2)"
			fi
		;;

		"test")
			result=`cd $root_path && mvn clean test -P$maven_profile -P $2 -Dtest=$3 $maven_additional`
			echo "$result"
		;;				

		"full")
			# TODO
			echo "`help`"
		;;

		"full-static")
			# TODO
			echo "`help`"
		;;								
    esac

else
	echo "`help`"
fi
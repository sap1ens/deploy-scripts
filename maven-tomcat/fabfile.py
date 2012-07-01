from fabric.api import local, settings
from fabric.utils import puts, warn

# root path for project, MUST HAS NOT trailing slash
root_path = "Main-app"

# list of paths with static files; from root_path
static_paths = [
    "webapp/src/main/webapp/templates",
    "webapp/src/main/webapp/recurly-js",
    "webapp/src/main/webapp/pages"
]

# path for Apache Tomcat root directory, MUST HAS NOT trailing slash
tomcat_path = "/Library/Tomcat"

# name of application
tomcat_app = "ROOT"

# "true" - Tomcat will be stopped by killing the process, recommended for local work
# "false" - Tomcat will be stopped by /bin/shutdown.sh script, recommended for production env
tomcat_hard_stop = True

# Maven profile for building
maven_profile = "local-slava"

# Maven can skip tests
maven_skip_tests = True

# additional options for Maven
maven_additional = "-o" # by default - make it offline

###

VERSION = "0.1"

###

def tomcat(action):
    if action == "start":
        puts("Tomcat is starting...")

        local("sh "+tomcat_path+"/bin/startup.sh")

    elif action == "stop":
        puts("Tomcat is stopping...")

        if tomcat_hard_stop:

            # there are can be a few tomcat instances, let's terminate them all
            processes_query = local("ps -axe | grep Tomcat | grep java | awk '{print $1}'", True)
            processes_ids = processes_query.split()

            for id in processes_ids:
                if int(id) > 0:
                    with settings(warn_only = True):
                        status = local("sudo kill -9 "+id)
                        if status.succeeded: puts("Killed procces: "+id)

        else:
            local("sh "+tomcat_path+"/bin/shutdown.sh")

    elif action == "restart":
        tomcat("stop")
        tomcat("start")

def static():
    for path in static_paths:
        local("sudo cp -R "+root_path+"/"+path+" "+tomcat_path+"/webapps/"+tomcat_app+"/")

def build():
    pass

def war():
    pass

def less():
    pass

# Example: mvn clean test -Plocal-user -P run-some-tests -Dtest=SomeTest -o
def test(profile, name):
    local("cd "+root_path+" && mvn clean test -P"+maven_profile+" -P "+profile+" -Dtest="+name+" "+maven_additional+"")

def db_test(name):
    test("run-db-tests", name)

def help():
    puts("""
    Usage: fab command:[arg1],[arg2]

    Description:
        Deployment (and not only...) tool for work in Apache Tomcat + Maven + ... + Less environment

    Required:
        Apache Tomcat 6+
        Apache Maven 2+
        Lessc compiler (optional)

    Commands:
        help                        - this page

        build                       - Maven package build
        war                         - copy current WAR package to Tomcat
        less                        - compile css files from Less
        static                      - copy current static files to Tomcat

        tomcat [start|stop|restart] - Tomcat management

        test [test profile] [name]  - run test with specified profile and class name with Maven
        db_test                     - run test with "run-db-tests" profile

        full                        - 'less' + 'build' + 'war' commands coherently
        full-static                 - 'less' + 'static' commands coherently
    """)

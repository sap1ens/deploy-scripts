from fabric.api import local, settings
from fabric.utils import puts, warn

# root path for project, MUST HAS NOT trailing slash
root_path = "~/work/demo"

# list of paths with static files; from root_path
static_paths = [
    "src/main/webapp/css",
    "src/main/webapp/js"
]

# path for Apache Tomcat root directory, MUST HAS NOT trailing slash
tomcat_path = "/Library/Tomcat"

# name of application
tomcat_app = "ROOT"

# "true" - Tomcat will be stopped by killing the process, recommended for local work
# "false" - Tomcat will be stopped by /bin/shutdown.sh script, recommended for production env
tomcat_hard_stop = True

# Maven profile for building
maven_profile = "user"

# Maven can skip tests
maven_skip_tests = "true"

# Maven module which should be deployed
maven_web_module = "webapp"

###

VERSION = "0.1"

###

def tomcat(action):
    if action == "start":
        puts("Tomcat is starting...")

        local("sh %s/bin/startup.sh" % tomcat_path)

    elif action == "stop":
        puts("Tomcat is stopping...")

        if tomcat_hard_stop:
            # there are can be a few tomcat instances, let's terminate them all
            processes_ids = local("ps -axe | grep Tomcat | grep java | awk '{print $1}'", True).split()

            for id in processes_ids:
                if int(id) > 0:
                    with settings(warn_only = True):
                        status = local("sudo kill -9 %s" % id)
                        if status.succeeded: puts("Killed procces: %s" % id)

        else:
            local("sh %s/bin/shutdown.sh" % tomcat_path)

    elif action == "restart":
        tomcat("stop")
        tomcat("start")

def static():
    for path in static_paths:
        local("cp -R %(root)s/%(path)s %(tpath)s/webapps/%(app)s/" % {
            "root": root_path,
            "path": path,
            "tpath": tomcat_path,
            "app": tomcat_app
        })

def build(module=None, maven_offline=True):
    local("cd %(path)s && mvn clean %(action)s -P%(profile)s -Dmaven.test.skip=%(skip)s %(extra)s" % {
        "path": root_path + "/" + module if module is not None else root_path,
        "action": "package" if module is not None else "install",
        "profile": maven_profile,
        "skip": maven_skip_tests,
        "extra": "-o" if maven_offline else ""
    })

def clean():
    local("rm -f %(path)s/webapps/%(app)s.war" % {
        "path": tomcat_path,
        "app": tomcat_app
    })
    local("rm -rf %(path)s/webapps/%(app)s" % {
        "path": tomcat_path,
        "app": tomcat_app
    })

def war():
    local("cd %(root)s/target && cp %(app)s.war %(path)s/webapps/%(app)s.war" % {
        'root': root_path + "/" + maven_web_module,
        'app': tomcat_app,
        'path': tomcat_path
    })

def test(profile, name, module=None, maven_offline=True):
    local("cd %(path)s && mvn clean test -P%(mprofile)s -P %(profile)s -Dtest=%(name)s %(extra)s" % {
        "path": root_path + "/" + module if module is not None else root_path,
        "mprofile": maven_profile,
        "profile": profile,
        "name": name,
        "extra": "-o" if maven_offline else ""
    })

def jpda():
    tomcat("stop")
    local("cd %s/bin && ./catalina.sh jpda start" % tomcat_path)

def full(module=None):
    build(module)
    tomcat("stop")
    war()
    tomcat("start")

def help():
    puts("""
    Usage: fab command:[arg1],[arg2]

    Description:
        Deployment (and not only...) tool for work in Apache Tomcat + Maven multi-module environment

    Required:
        Apache Tomcat 6+
        Apache Maven 2+

    Commands:
        help                        - this page

        build                       - Maven package build
        war                         - copy current WAR package to Tomcat
        static                      - copy current static files to Tomcat

        tomcat:[start|stop|restart] - Tomcat management
        clean                       - clean deployed Tomcat app
        jpda                        - run Tomcat's JPDA

        test:[test profile],[name]  - run test with specified profile and class name with Maven

        full                        - 'build' + 'tomcat:stop' + 'war' + 'tomcat:start' commands coherently
    """)

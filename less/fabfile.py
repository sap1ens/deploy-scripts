from fabric.api import local

# prefix for "paths", without trailing slash, can be empty
path_prefix = "~/work/demo"

paths = [
    {"less": "app/less/main", "css": "app/assets/css/main", "min": True},
    {"less": "press/assets/less/main", "css": "press/assets/css/main", "min": False}
]

def compile():
    for path in paths:
        less = path_prefix + "/" + path["less"]
        css = path_prefix + "/" + path["css"]

        local("lessc %(less)s > %(css)s" % {
            "less": less + ".less",
            "css": css + ".css"
        })

        if path["min"]:
            local("lessc %(less)s > %(css)s --compress" % {
                "less": less + ".less",
                "css": css + ".min.css"
            })

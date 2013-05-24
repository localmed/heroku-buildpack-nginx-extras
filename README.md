Heroku Nginx Buildpack w/ Extras
================================

This is a standard Nginx build with most, if not all, of the `--with-XXX` flags included in the configuration, as well as some extra third-party modules. The goal is to add as many extra modules as we can without making the server too bloated. 

Some includes and modules, however, require binary dependencies that need to be installed on the Heroku app in order to function. In turn, they will require some significant scripting and prep to include in the build and, thus, will not be added initially for that very reason.

Current Includes And Modules
----------------------------
* PCRE `--with-pcre`
* IPV6 `--with-ipv6`
* Addition `--with-http_addition_module`
* Many More!
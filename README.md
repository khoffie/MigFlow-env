# MigFlow-env
Creates a nix-shell that installs everything needed to run and
reproduce the [MigFlow](https://github.com/khoffie/MigFlow) project.
The shell downloads and installs all `Julia`,`R` , all packages and
all dependencies.

**Work in progress. Specifically I did not try it yet in a completely
isolated environment. For me the build works, but possibly Julia uses
precompiled packages. On other systems the build may fail. Also, there
are unnecessary dependencies.**

---
name: Bug report
about: Report a bug
labels: bug
---

Please supply your brew configuration:

~~~
$ brew config

~~~

If you are reporting a build failure, please supply the build logs
with the `--verbose` flag:

~~~
brew install gazebo7 --verbose
brew gist-logs gazebo7
~~~

then include the link in the issue. Thanks!

# mycourses.ntua.gr-Downloader

Script to easily download content and manage local copies of the mycourses.ntua.gr CMS.
Be sure to share it!!

# Usage
```sh
$ chmod +x my_get.sh
$  ./my_get.sh -c [COURSE] -l [location] -f [file] -w [workdir] -t [tabs] -u [USERNAME] -p [PASSWORD] -a -ow -u -h
```
| OPTION | Alternative | Function | Internal
| ------ | ------ |------ |------ |
| -c |--course| Enter Course Name as found on MyCourses e.g. http://mycourses.ntua.gr/course_description/index.php?cidReq=MECH1145 -> MECH1145 | no|
| -l | --location| location | yes|
|-f | --file | FILE| yes|
| -w | --workdir |Working Directory| no|
| -t | --tabs | TABS| yes|
| -u | --username |Username for MyCourses | no|
| -p | --password |Password for MyCourses |no|
| -a | --all | Option to download all registered courses| no
|-ow | --overwrite | Overwrite previous downloads| no
| -u | --update| Try to Update any previous downloads|no
| -h | --help |Display Help|no


### Todos

 - Write Update Jobs

License
----

GPLv3

# A Salt formula for deploying Gerrit and Jenkins

This formula installs Gerrit, MySQL, Jenkins, and the gerrit-trigger jenkins
plugin.

#### Before using

The included setup.sh script will create ssh-rsa keys and create a necessary
uuids.
```shell
bash setup.sh
```

This formula is role based. It will look for roles in a grain called
roles.

Sample pillar data and a sample top file are included.

#### How to use
```shell
sudo salt-run state.sls gerrit_ci.runner
```
#### Helpful links
* [Gerrit](https://code.google.com/p/gerrit/)
* [Jenkins](http://jenkins-ci.org/)
* [Gerrit Trigger](https://wiki.jenkins-ci.org/display/JENKINS/Gerrit+Trigger)
* [MySQL](http://www.mysql.com/)

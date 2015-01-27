include:
  - gerrit_ci.java

jenkins:
  user.present:
    - shell: /bin/bash

jenkins-slave-key:
  ssh_auth.present:
    - user: jenkins
    - source: salt://gerrit_ci/jenkins/files/keys/id_rsa.pub
    - require:
      - user: jenkins

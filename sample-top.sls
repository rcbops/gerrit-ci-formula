base:

  'roles:gerrit':
    - match: grain
    - gerrit_ci

  'roles:jenkins':
    - match: grain
    - gerrit_ci

  'roles:jenkins_slave':
    - match: grain
    - gerrit_ci.jenkins.slave

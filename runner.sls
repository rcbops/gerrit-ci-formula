gerrit and jenkins slaves:
  salt.state:
    - tgt: 'G@roles:jenkins_slave or G@roles:gerrit'
    - tgt_type: compound
    - highstate: True

jenkins:
  salt.state:
    - tgt: 'roles:jenkins'
    - tgt_type: grain
    - highstate: True
    - require:
      - salt: gerrit and jenkins slaves

configure:
  salt.state:
    - tgt: 'roles:jenkins'
    - tgt_type: grain
    - sls:
      - gerrit_ci.jenkins.configure
    - require:
      - salt: jenkins

plugins:
  salt.state:
    - tgt: 'roles:jenkins'
    - tgt_type: grain
    - sls:
      - gerrit_ci.jenkins.plugins
    - require:
      - salt: configure

jenkins-slaves:
  salt.state:
    - tgt: 'roles:jenkins'
    - tgt_type: grain
    - sls:
      - gerrit_ci.jenkins.setup_slaves
    - require:
      - salt: plugins

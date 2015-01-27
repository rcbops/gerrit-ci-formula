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

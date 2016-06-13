interfaces:
  public: eth0
  private: eth2
mine_functions:
  network.ip_addrs: [eth0]
  grains.get: [num_cpus]
mine_interval: 1

gerrit:
  version: 2.9.3
  #canonicalWebUrl: https://someaddress/
  http_virtual_host: '*:80'
  https_virtual_host: '*:443'
  #https_url: https://someaddress
  #server_name: someservername
  proxy_pass_url: http://127.0.0.1:8081/
  sshdlistenaddress: '*:29418'
  httpdlistenurl: proxy-https://127.0.0.1:8081/r/

{% if 'gerrit' in salt['grains.get']('roles', []) %}
  dbname: gerrit
  dbhost: localhost
  dbuserhost: localhost
  dbuser: gerrit
  dbpassword: gerrit
{% endif %}

{% if 'jenkins' in salt['grains.get']('roles', []) %}

jenkins:
  username: jenkins
  password: apassword
  email: someemail@somedomain.com
  server_name: jenkins_server_name
  https_url: https://jenkins-ip
  plugins:
    - gerrit-trigger
    - git
    - ssh-credentials
    - ssh-slaves
  gerrit:
    frontEndUrl: https://gerrit-ip
  manual_plugins:
    matrix-auth: http://updates.jenkins-ci.org/download/plugins/matrix-auth/1.3/matrix-auth.hpi
{% endif %}

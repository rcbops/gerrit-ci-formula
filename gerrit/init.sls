{% from "gerrit_ci/gerrit/settings.sls" import gerrit with context %}
include:
  - gerrit_ci.java

# Software
required-software:
  pkg.installed:
    - pkgs:
      - mysql-server
      - python-mysqldb
      - wget
      - apache2
    - require:
      - sls: gerrit_ci.java

# gerrit2 user
gerrit2:
  group:
    - present

  user.present:
    - home: /home/gerrit2
    - shell: /bin/bash
    - groups:
      - gerrit2

# Mysql service
mysql:
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: required-software

# database
gerrit-database:
  mysql_database.present:
    - name: {{ gerrit.dbname }}
    - require:
      - service: mysql

  mysql_user.present:
    - name: {{ gerrit.dbuser }}
    - host: {{ gerrit.dbhost }}
    - password: {{ gerrit.dbpassword }}
    - require:
      - service: mysql

  mysql_grants.present:
    - grant: all privileges
    - database: {{ gerrit.dbname }}.*
    - user: {{ gerrit.dbuser }}
    - require:
      - service: mysql

# Gerrit war
/home/gerrit2/gerrit-{{ gerrit.version }}.war:
  cmd.run:
    - name: wget {{ gerrit.war_url }}
    - cwd: /home/gerrit2
    - user: gerrit2
    - onlyif: test ! -s gerrit-{{ gerrit.version }}.war
    - require:
      - user: gerrit2

/var/log/gerrit:
  file.directory:
    - user: gerrit2
    - group: gerrit2
    - require:
      - user: gerrit2
      - group: gerrit2

/home/gerrit2/review_site:
  file.directory:
    - owner: gerrit2
    - group: gerrit2
    - require:
      - user: gerrit2

/home/gerrit2/.ssh:
  file.directory:
    - owner: gerrit2
    - group: gerrit2
    - mode: 700
    - require:
      - user: gerrit2

/home/gerrit2/.ssh/id_rsa:
  file.managed:
    - source: salt://gerrit_ci/gerrit/files/keys/id_rsa
    - owner: gerrit2
    - group: gerrit2
    - mode: 0600
    - require:
      - file: /home/gerrit2/.ssh

/home/gerrit2/.ssh/id_rsa.pub:
  file.managed:
    - source: salt://gerrit_ci/gerrit/files/keys/id_rsa.pub
    - owner: gerrit2
    - group: gerrit2
    - mode: 644
    - require:
      - file: /home/gerrit2/.ssh

/home/gerrit2/review_site/etc:
  file.directory:
    - owner: gerrit2
    - group: gerrit2
    - require:
      - user: gerrit2
      - file: /home/gerrit2/review_site

/home/gerrit2/review_site/etc/gerrit.config:
  file.managed:
    - source: salt://gerrit_ci/gerrit/files/gerrit.config
    - mode: 0644
    - owner: gerrit2
    - group: gerrit2
    - replace: False
    - template: jinja
    - require:
      - file: /home/gerrit2/review_site/etc

# Init gerrit
gerrit-init:
  cmd.run:
    - name: java -jar /home/gerrit2/gerrit-{{ gerrit.version }}.war init --batch -d /home/gerrit2/review_site --no-auto-start {% for plugin in gerrit.plugins %} --install-plugin {{ plugin }} {% endfor %}
    - user: gerrit2
    - watch:
      - cmd: /home/gerrit2/gerrit-{{ gerrit.version }}.war

# Rebuild indexes
gerrit-index:
  cmd.run:
    - name: java -jar /home/gerrit2/review_site/bin/gerrit.war reindex -d /home/gerrit2/review_site
    - user: gerrit2
    - require:
      - cmd: gerrit-init
    - onlyif: test ! -e /home/gerrit2/review_site/index/gerrit_index.config

/home/gerrit2/review_site/bin/gerrit.sh:
  file.uncomment:
    - char: '#'
    - regex: '((chkconfig: 3 99 99)|(description: Gerrit Code Review)|(processname: gerrit))'
    - require:
      - cmd: gerrit-init
      - cmd: gerrit-index

/etc/init.d/gerrit:
  file.symlink:
    - target: /home/gerrit2/review_site/bin/gerrit.sh
    - require:
      - file: /home/gerrit2/review_site/bin/gerrit.sh

/etc/rc3.d/s90gerrit:
  file.symlink:
    - target: /etc/init.d/gerrit
    - require:
      - file: /etc/init.d/gerrit

/etc/default/gerritcodereview:
  file.managed:
    - source: salt://gerrit_ci/gerrit/files/gerritcodereview
    - replace: True

gerrit-service:
  service.running:
    - name: gerrit
    - enable: True
    - watch:
      - file: /home/gerrit2/review_site/etc/gerrit.config
    - require:
      - cmd: gerrit-init
      - cmd: gerrit-index
      - file: /etc/default/gerritcodereview

gerrit known host:
  ssh_known_hosts.present:
    - name: localhost
    - port: 29418
    - user: gerrit2
    - hash_hostname: True
    - require:
      - user: gerrit2

initial_accounts:
  cmd.script:
    - source: salt://gerrit_ci/gerrit/files/initial_accounts.sh
    - template: jinja
    - user: gerrit2
    - require:
      - service: gerrit-service

add verified label:
  cmd.script:
    - source: salt://gerrit_ci/gerrit/files/initial_all_projects.sh
    - template: jinja
    - cwd: /home/gerrit2
    - onlyif: test ! -e /home/gerrit2/.initial_all_projects_configured
    - user: gerrit2
    - require:
      - ssh_known_hosts: gerrit known host
      - cmd: initial_accounts

# Apache
a2enmod proxy_http:
  cmd.run:
    - onlyif: test ! -s /etc/apache2/mods-enabled/proxy_http.load
    - require:
      - pkg: required-software

a2enmod ssl:
  cmd.run:
    - onlyif: test ! -s /etc/apache2/mods-enabled/ssl.conf
    - require:
      - pkg: required-software

/etc/apache2/sites-available/default:
  file.absent:
    - require:
      - pkg: required-software

/etc/apache2/sites-available/default-ssl:
  file.absent:
    - require:
      - pkg: required-software

/etc/apache2/sites-enabled/000-default:
  file.absent:
    - require:
      - pkg: required-software

/etc/apache2/sites-available/gerrit:
  file.managed:
    - require:
      - pkg: required-software
    - source: salt://gerrit_ci/gerrit/files/gerrit.vhost
    - template: jinja
    - replace: True

/etc/apache2/sites-enabled/000-gerrit:
  file.symlink:
    - target: /etc/apache2/sites-available/gerrit
    - require:
      - file: /etc/apache2/sites-available/gerrit

self-signed-cert:
  cmd.run:
    - name: openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/certs/gerrit.key -out /etc/ssl/certs/gerrit.crt -days 999 -subj "/CN={{ salt['network.ipaddrs']('eth0')[0] }}"
    - unless: test -s /etc/ssl/certs/gerrit.crt

apache2:
  service.running:
    - enable: True
    - watch:
      - cmd: a2enmod proxy_http
      - cmd: a2enmod ssl
      - file: /etc/apache2/sites-available/gerrit
    - require:
      - file: /etc/apache2/sites-enabled/000-gerrit
      - file: /etc/apache2/sites-enabled/000-default
      - cmd: self-signed-cert

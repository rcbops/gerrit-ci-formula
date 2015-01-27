{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
include:
  - gerrit_ci.java

# jenkins repo
jenkins-repo:
  pkgrepo.managed:
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - key_url: https://jenkins-ci.org/debian/jenkins-ci.org.key
    - require_in:
      - pkg: required-software

# Software
required-software:
  pkg.installed:
    - pkgs:
      - jenkins
      - jenkins-cli
      - apache2
    - require:
      - sls: gerrit_ci.java

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

a2enmod headers:
  cmd.run:
    - onlyif: test ! -s /etc/apache2/mods-enabled/headers.load
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

/etc/apache2/sites-available/jenkins:
  file.managed:
    - require:
      - pkg: required-software
    - source: salt://gerrit_ci/jenkins/files/vhost
    - template: jinja
    - replace: True

/etc/apache2/sites-enabled/111-jenkins:
  file.symlink:
    - target: /etc/apache2/sites-available/jenkins
    - require:
      - file: /etc/apache2/sites-available/jenkins

self-signed-cert:
  cmd.run:
    - name: openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/certs/jenkins.key -out /etc/ssl/certs/jenkins.crt -days 999 -subj "/CN={{ salt['network.ipaddrs']('eth0')[0] }}"
    - unless: test -s /etc/ssl/certs/jenkins.crt

apache2:
  service.running:
    - enable: True
    - watch:
      - cmd: a2enmod proxy_http
      - cmd: a2enmod ssl
      - cmd: a2enmod headers
      - file: /etc/apache2/sites-available/jenkins
    - require:
      - file: /etc/apache2/sites-enabled/111-jenkins
      - file: /etc/apache2/sites-enabled/000-default
      - cmd: self-signed-cert

{{ jenkins.home }}/.ssh:
  file.directory:
    - owner: jenkins
    - group: jenkins
    - mode: 700
    - require:
      - pkg: required-software

{{ jenkins.home }}/updates:
  file.directory:
    - owner: jenkins
    - group: jenkins
    - require:
      - pkg: required-software

{{ jenkins.home }}/credentials.xml:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/credentials.xml
    - template: jinja
    - owner: jenkins
    - group: jenkins
    - replace: False
    - require:
      - pkg: required-software

jenkins-plugins-list:
  cmd.script:
    - source: salt://gerrit_ci/jenkins/files/pluginlist.sh
    - onlyif: test ! -s {{ jenkins.home }}/updates/default.json
    - template: jinja
    - requires:
      - file: {{ jenkins.home }}/updates

{{ jenkins.home }}/.ssh/id_rsa:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/keys/id_rsa
    - owner: jenkins
    - group: jenkins
    - mode: 700
    - require:
      - file: {{ jenkins.home }}/.ssh

{{ jenkins.home }}/.ssh/id_rsa.pub:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/keys/id_rsa.pub
    - owner: jenkins
    - group: jenkins
    - mode: 744
    - require:
      - file: {{ jenkins.home }}/.ssh

{{ jenkins.home }}/config.xml:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/config.xml
    - template: jinja
    - owner: jenkins
    - group: jenkins
    - replace: False
    - require:
      - pkg: required-software

{{ jenkins.home }}/gerrit-trigger.xml:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/gerrit-trigger.xml
    - template: jinja
    - owner: jenkins
    - group: jenkins
    - replace: False
    - require:
      - pkg: required-software

{{ jenkins.home }}/users:
  file.directory:
    - owner: jenkins
    - group: jenkins
    - require:
      - pkg: required-software

{{ jenkins.home }}/users/{{ jenkins.username }}:
  file.directory:
    - owner: jenkins
    - group: jenkins
    - require:
      - file: {{ jenkins.home }}/users

{{ jenkins.home }}/users/{{ jenkins.username }}/config.xml:
  file.managed:
    - owner: jenkins
    - group: jenkins
    - template: jinja
    - source: salt://gerrit_ci/jenkins/files/user-config.xml
    - replace: False
    - require:
      - file: {{ jenkins.home }}/users/{{ jenkins.username }}
      - file: {{ jenkins.home }}/.ssh/id_rsa
      - file: {{ jenkins.home }}/.ssh/id_rsa.pub

jenkins-service:
  service.running:
    - name: jenkins
    - enable: True
    - watch:
      - file: {{ jenkins.home }}/config.xml
      - file: {{ jenkins.home }}/gerrit-trigger.xml
      - file: {{ jenkins.home }}/users/{{ jenkins.username }}/config.xml
      - cmd: jenkins-plugins-list
    - require:
      - file: {{ jenkins.home }}/config.xml
      - file: {{ jenkins.home }}/credentials.xml
      - file: {{ jenkins.home }}/gerrit-trigger.xml
      - file: {{ jenkins.home }}/users/{{ jenkins.username }}/config.xml
      - pkg: required-software
      - cmd: jenkins-plugins-list

{% for plugin in jenkins.plugins %}
jenkins-plugin-{{ plugin }}:
  cmd.script:
    - name: install-plugin {{ plugin }}
    - source: salt://gerrit_ci/jenkins/files/install-plugin.sh
    - template: jinja
    - user: jenkins
    - onlyif: test ! -s {{ jenkins.home }}/plugins/{{ plugin }}.jpi
    - require:
      - service: jenkins-service
      - pkg: required-software
{% endfor %}

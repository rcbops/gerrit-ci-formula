{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
{% for plugin in jenkins.plugins %}
jenkins-plugin-{{ plugin }}:
  cmd.script:
    - name: install-plugin {{ plugin }}
    - source: salt://gerrit_ci/jenkins/files/install-plugin.sh
    - template: jinja
    - user: jenkins
    - onlyif: test ! -s {{ jenkins.home }}/plugins/{{ plugin }}.jpi
{% endfor %}

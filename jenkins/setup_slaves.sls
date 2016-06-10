{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
{{ jenkins.home }}/nodes:
  file.directory:
    - user: jenkins
    - group: jenkins

{% for id, slave in jenkins.slaves.iteritems() %}
{{ jenkins.home }}/nodes/{{ id }}:
  file.directory:
    - owner: jenkins
    - group: jenkins
    - require:
      - file: {{ jenkins.home }}/nodes

{{ jenkins.home}}/nodes/{{ id }}/config.xml:
  file.managed:
    - owner: jenkins
    - group: jenkins
    - template: jinja
    - source: salt://gerrit_ci/jenkins/files/node_config.xml
    - context:
        id: {{ id }}
        host: {{ slave.host }}
        numExecutors: {{ slave.numExecutors }}
    - require:
      - file: {{ jenkins.home }}/nodes/{{ id }}
    - watch_in:
      - service: jenkins
{% endfor %}

jenkins:
  service.running

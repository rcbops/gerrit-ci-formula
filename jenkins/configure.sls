{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
# Warning, this state is destructive
# only use when starting jenkins for the first time
# It is possible to lose configuration when using this state.
{{ jenkins.home }}/config.xml:
  file.managed:
    - source: salt://gerrit_ci/jenkins/files/config.xml
    - template: jinja
    - user: jenkins
    - group: jenkins

jenkins:
  service.running:
    - watch:
      - file: {{ jenkins.home }}/config.xml

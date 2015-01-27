{% set roles = salt['grains.get']('roles') %}
include:
{% if 'gerrit' in roles %}
  - gerrit_ci/gerrit
{% endif %}
{% if 'jenkins' in roles %}
  - gerrit_ci/jenkins
{% endif %}


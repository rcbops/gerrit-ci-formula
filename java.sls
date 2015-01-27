# jdk/jre
openjdk-7-jdk:
  pkg:
    - installed

{% if 'jenkins' in salt['grains.get']('roles') %}
openjdk-7-jre:
  pkg:
    - installed
{% endif %}

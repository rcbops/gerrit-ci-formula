{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
#!/bin/bash
cd {{ jenkins.home }}/updates
wget -O default.js http://updates.jenkins-ci.org/update-center.json
sed '1d;$d' default.js > default.json
rm default.js

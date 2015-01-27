{%- from "gerrit_ci/jenkins/settings.sls" import jenkins with context -%}
#!/bin/bash -e
while [ $(curl -s -o /dev/null -I -w "%{http_code}" http://localhost:8080/) != "200" ]; do
    echo "Waiting for jenkins service to respond"
    sleep 5
done
jenkins-cli -s http://localhost:8080 install-plugin $1 -deploy

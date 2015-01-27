{% from "gerrit_ci/gerrit/settings.sls" import gerrit with context %}
#!/bin/bash -e
git clone ssh://{{ gerrit.initial_user.username }}@localhost:29418/All-Projects.git
cd All-Projects

git config user.name "{{ gerrit.initial_user.full_name }}"
git config user.email "{{ gerrit.initial_user.email }}"
git fetch origin refs/meta/config:refs/remotes/origin/meta/config
git checkout meta/config

cat <<'EOF' > project.config
{% include 'gerrit_ci/gerrit/files/project.config' without context %}
EOF

git commit -a -m "Added label Verified and permissions to vote verified to non interactive users."
git push origin meta/config:meta/config
cd ..
rm -rf All-Projects
touch /home/gerrit2/.initial_all_projects_configured

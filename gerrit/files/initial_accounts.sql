{% from "gerrit_ci/gerrit/settings.sls" import gerrit with context %}
INSERT INTO accounts (account_id,full_name, preferred_email)
    SELECT 1,'{{ gerrit.initial_user.full_name }}','{{ gerrit.initial_user.email }}' FROM DUAL WHERE NOT EXISTS (SELECT * from accounts)
UNION ALL
    SELECT 2, NULL, NULL FROM DUAL WHERE NOT EXISTS (SELECT * FROM accounts);

INSERT INTO account_group_members (account_id, group_id)
    SELECT 1,1 FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_group_members)
UNION ALL
    SELECT 2,2 FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_group_members);

INSERT INTO account_id (s)
    SELECT 1 FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_id)
UNION ALL
    SELECT 2 FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_id);

INSERT INTO account_group_members_audit (added_by,account_id,group_id,added_on)
    SELECT 1,1,1, NOW() FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_group_members_audit)
UNION ALL
    SELECT 1,2,2, NOW() FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_group_members_audit);

INSERT INTO account_external_ids (account_id, external_id, email_address)
    SELECT 1,'username:{{ gerrit.initial_user.username }}','{{ gerrit.initial_user.email}}' FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_external_ids)
UNION ALL
    SELECT 2,'username:jenkins',NULL FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_external_ids);

INSERT INTO account_ssh_keys (account_id, seq, valid, ssh_public_key)
    SELECT 1,1,'Y','{%- include 'gerrit_ci/gerrit/files/keys/id_rsa.pub' without context -%}' FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_ssh_keys)
UNION ALL
    SELECT 2,1,'Y','{%- include 'gerrit_ci/jenkins/files/keys/id_rsa.pub' without context -%}' FROM DUAL WHERE NOT EXISTS (SELECT * FROM account_ssh_keys);

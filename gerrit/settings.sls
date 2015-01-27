{% set public = salt['pillar.get']('gerrit:interfaces:public', 'eth0') %}
{% set ip = salt['network.ip_addrs']('eth0')[0] %}
{% set version = salt['pillar.get']('gerrit:version', '2.9.3') %}
{% set gerrit = {
    'war_url': 'https://gerrit-releases.storage.googleapis.com/gerrit-' + version + '.war',
    'canonicalWebUrl': salt['pillar.get']('gerrit:canonicalWebUrl', 'https://' + ip + '/'),
    'http_virtual_host': salt['pillar.get']('gerrit:http_virtual_host', '*:80'),
    'https_virtual_host': salt['pillar.get']('gerrit:https_virtual_host', '*:443'),
    'https_url': salt['pillar.get']('gerrit:https_url', 'https://' + ip + '/'),
    'server_name': salt['pillar.get']('gerrit:server_name', ip),
    'proxy_pass_url': salt['pillar.get']('gerrit:proxy_pass_url', 'http://127.0.0.1:8081/'),
    'version': version,
    'dbname': salt['pillar.get']('gerrit:dbname', 'gerrit'),
    'dbuser': salt['pillar.get']('gerrit:dbuser', 'gerrit'),
    'dbhost': salt['pillar.get']('gerrit:dbhost', 'localhost'),
    'dbuserhost': salt['pillar.get']('gerrit:dbhost', 'gerrit'),
    'dbpassword': salt['pillar.get']('gerrit:dbpassword', 'gerrit'),
    'sshdlistenaddress': salt['pillar.get']('gerrit.sshdlistenaddress', '*:29418'),
    'httpdlistenurl': salt['pillar.get']('gerrit.httpdlistenurl', 'proxy-https://127.0.0.1:8081/'),
    'plugins': ['download-commands', 'replication', 'commit-message-length-validator'],
    'initial_user': {
        'full_name': salt['pillar.get']('gerrit:initial_user:full_name', 'Gerrit Admin'),
        'email': salt['pillar.get']('gerrit:initial_user:email', 'gerritadmin@yourdomain.com'),
        'username': salt['pillar.get']('gerrit:initial_user:username', 'gerritadmin')
    }
} %}

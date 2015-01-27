{% set jenkins_home = '/var/lib/jenkins' %}
{% set interface = salt['pillar.get']('interfaces:public', 'eth0') %}
{% set ip = salt['network.ip_addrs'](interface)[0] %}
{% set gerrit_ip = salt['mine.get']('roles:gerrit', 'network.ip_addrs', 'grain').values()[0][0] %}

{% set slaves = {} %}
{% for id, ip_addrs in salt['mine.get']('roles:jenkins_slave', 'network.ip_addrs', 'grain').iteritems() %}
    {% do slaves.update({
        id: {
            'host': ip_addrs[0],
            'numExecutors': salt['mine.get'](id, 'grains.get').values()[0]
        }
    }) %}
{% endfor %}

{% set jenkins = {
    'home': salt['pillar.get']('jenkins:home', jenkins_home),
    'username': salt['pillar.get']('jenkins:username', 'admin'),
    'password': salt['pillar.get']('jenkins:password', 'changeme'),
    'email': salt['pillar.get']('jenkins:email', '123@123.com'),
    'plugins': salt['pillar.get']('jenkins:plugins', ['gerrit-trigger', 'git']),
    'slaves': slaves,
    'http_virtual_host': salt['pillar.get']('jenkins:http_virtual_host', '*:80'),
    'https_virtual_host': salt['pillar.get']('jenkins:https_virtual_host', '*:443'),
    'https_url': salt['pillar.get']('jenkins:https_url', 'https://' + ip + '/'),
    'server_name': salt['pillar.get']('jenkins:server_name', ip),
    'proxy_pass_url': salt['pillar.get']('jenkins:proxy_pass_url', 'http://localhost:8080/'),
    'gerrit': {
        'name': salt['pillar.get']('jenkins:gerrit:name', 'gerrit'),
        'host': salt['mine.get']('roles:gerrit', 'network.ip_addrs', 'grain').values()[0][0],
        'port': salt['pillar.get']('jenkins:gerrit:port', '29418'),
        'username': salt['pillar.get']('jenkins:gerrit:username', 'jenkins'),
        'email': salt['pillar.get']('jenkins:gerrit:email', '123@123.com'),
        'authKeyFile': salt['pillar.get']('jenkins:gerrit:authKeyFile', jenkins_home + '/.ssh/id_rsa'),
        'frontEndUrl': salt['pillar.get']('jenkins:gerrit:frontEndUrl', 'https://' + gerrit_ip + '/')
    }
} %}

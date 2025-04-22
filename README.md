# ansible-executor-environment
![Docker Build](https://github.com/fbraz3/ansible-executor-environment/actions/workflows/docker-image.yml/badge.svg
)

Custom Ansible execution environment :: [Images on DockerHub](https://hub.docker.com/r/fbraz3/ansible-executor-environment)

the follow galaxy roles are installed by default

- ansible.posix
- community.zabbix
- community.general
- community.vmware
- dseeley.esxifree_guest
- awx.awx
- julien_lecomte.proxmox

And the follow python packages

- pycurl
- PyVmomi

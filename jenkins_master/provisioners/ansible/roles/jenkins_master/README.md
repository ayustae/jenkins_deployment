Role Name
=========

An Ansible role to install the Jenkins master.

Requirements
------------

This role requires a RHEL-compatible Linux distribution.

Role Variables
--------------

- java_version               -> The Java version to install (default: 8).
- jenkins_use_stable_version -> Whether to use the 'stable' or the 'latest' Jenkins version (default: true).
- jenkins_home_folder        -> Jenkins installation folder (default: /var/lib/jenkins).
- jenkins_host_user          -> Linux user to be used by Jenkins (default: jenkins).
- jenkins_host_group         -> Linux group to be used by Jenkins (default: the same as 'jenkins_host_user').
- jenkins_hostname           -> Hostname of the Jenkins service (default: localhost).
- jenkins_port               -> Port of the Jenkins service (default: 8080).
- jenkins_path               -> URL path of the Jenkins service (default: "").

Example Playbook
----------------

# Ansible template to configure the Jenkins Master
---

- hosts: master_host
  become: true
  gather_facts: true
  roles:
    - role: jenkins_master

License
-------

BSD

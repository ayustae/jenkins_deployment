#!/bin/bash

echo "${vault_password}" > "${module_path}/provisioners/ansible/vault_password_file.txt"

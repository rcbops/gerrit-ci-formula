#!/bin/bash
mysql -uroot gerrit -e "{%- include 'gerrit_ci/gerrit/files/initial_accounts.sql' with context -%}"

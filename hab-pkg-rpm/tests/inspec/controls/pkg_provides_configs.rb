# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'package provides configs'
#

# %config(noreplace) /etc/backup-script.conf
# %config(noreplace) /etc/hello-world.conf

control 'pkg_provides_configs' do
  title 'Package provides list of config files it manages'
  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_configs/SPECS/core-netcat.spec') do
    its('content') { should match('%config\(noreplace\) /etc/backup-script.conf') }
    its('content') { should match('%config\(noreplace\) /etc/hello-world.conf') }
  end
end

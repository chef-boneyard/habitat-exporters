# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'package provides description'
#

control 'pkg_provides_description' do
  title 'Package provides description in its plan.sh'
  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_description/SPECS/core-netcat.spec') do
    its('content') { should match('description\nGNU rewrite of the OpenBSD netcat/nc package') }
  end
end

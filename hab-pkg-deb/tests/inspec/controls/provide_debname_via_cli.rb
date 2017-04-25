# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide exported package name via CLI'
#

control 'pkg_name_via_cli' do
  title 'Provide exported package name via CLI'
  describe file('/tmp/test-hab-pkg-deb-set_debname/DEBIAN/control') do
    its('content') { should match('Package: hogwarts') }
    its('content') { should match('Description: hogwarts') }
  end
end

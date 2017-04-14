# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Package provides its own control template'
#

control 'pkg_provides_control_template' do
  title 'Package provides its own control template'
  describe file('/tmp/test-hab-pkg-deb-pkg_includes_control_template/DEBIAN/control') do
    its('content') { should match('This: is a control file provided by a package') }
  end
end

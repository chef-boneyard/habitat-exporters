# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Package provides its own install scripts'
#

control 'pkg_provides_install_scripts' do
  title 'Package provides its own install scripts'
  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_post/SPECS/core-netcat.spec') do
    its('content') { should match("%post\necho \"This is a fake post script.\"") }
  end

  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_postun/SPECS/core-netcat.spec') do
    its('content') { should match("%postun\necho \"This is a fake postun script.\"") }
  end

  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_pre/SPECS/core-netcat.spec') do
    its('content') { should match("%pre\necho \"This is a fake pre script.\"") }
  end

  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_preun/SPECS/core-netcat.spec') do
    its('content') { should match("%preun\necho \"This is a fake preun script.\"") }
  end
end

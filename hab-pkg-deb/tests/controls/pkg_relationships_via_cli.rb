# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide package relationship via CLI'
#

control 'pkg_relationships_via_cli' do
  title 'Provide package relationship via CLI'

  describe file('/tmp/test-hab-pkg-deb-conflicts/DEBIAN/control') do
    its('content') { should match('Conflicts: snape') }
  end

  describe file('/tmp/test-hab-pkg-deb-depends/DEBIAN/control') do
    its('content') { should match('Depends: hermione') }
  end

  describe file('/tmp/test-hab-pkg-deb-provides/DEBIAN/control') do
    its('content') { should match('Provides: harry') }
  end

  describe file('/tmp/test-hab-pkg-deb-replaces/DEBIAN/control') do
    its('content') { should match('Replaces: draco') }
  end
end

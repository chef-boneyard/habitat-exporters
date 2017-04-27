# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Package provides its own install scripts'
#

control 'pkg_provides_install_scripts' do
  title 'Package provides its own install scripts'
  describe file('/tmp/test-hab-pkg-deb-pkg_provides_postinst/DEBIAN/postinst') do
    its('content') { should match('This is a fake postinst script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-pkg_provides_postrm/DEBIAN/postrm') do
    its('content') { should match('This is a fake postrm script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-pkg_provides_preinst/DEBIAN/preinst') do
    its('content') { should match('This is a fake preinst script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-pkg_provides_prerm/DEBIAN/prerm') do
    its('content') { should match('This is a fake prerm script.') }
  end
end

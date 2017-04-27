# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide install scripts via CLI'
#

control 'install_scripts_via_cli' do
  title 'Provide install scripts via CLI'
  describe file('/tmp/test-hab-pkg-deb-cli_includes_postinst/DEBIAN/postinst') do
    its('content') { should match('This is another fake postinst script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-cli_includes_postrm/DEBIAN/postrm') do
    its('content') { should match('This is another fake postrm script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-cli_includes_preinst/DEBIAN/preinst') do
    its('content') { should match('This is another fake preinst script.') }
  end

  describe file('/tmp/test-hab-pkg-deb-cli_includes_prerm/DEBIAN/prerm') do
    its('content') { should match('This is another fake prerm script.') }
  end
end

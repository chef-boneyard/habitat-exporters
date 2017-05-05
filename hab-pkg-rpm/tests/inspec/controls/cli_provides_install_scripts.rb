# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide install scripts via CLI'
#

control 'cli_provides_install_scripts' do
  title 'Provide install scripts via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_post/SPECS/core-netcat.spec') do
    its('content') { should match('This is another fake post script.') }
  end

  describe file('/tmp/test-hab-pkg-rpm-cli_provides_postun/SPECS/core-netcat.spec') do
    its('content') { should match('This is another fake postun script.') }
  end

  describe file('/tmp/test-hab-pkg-rpm-cli_provides_pre/SPECS/core-netcat.spec') do
    its('content') { should match('This is another fake pre script.') }
  end

  describe file('/tmp/test-hab-pkg-rpm-cli_provides_preun/SPECS/core-netcat.spec') do
    its('content') { should match('This is another fake preun script.') }
  end
end

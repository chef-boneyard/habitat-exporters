# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide priority via CLI'
#

control 'cli_provides_priority' do
  title 'Provide priority via CLI'
  describe file('/tmp/test-hab-pkg-deb-cli_override_priority/DEBIAN/control') do
    its('content') { should match('Priority: highest') }
  end
end

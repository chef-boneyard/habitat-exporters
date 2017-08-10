# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide section via CLI'
#

control 'cli_provides_group' do
  title 'Provide group via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_group/SPECS/core-netcat.spec') do
    its('content') { should match('Group: somegroup') }
  end
end

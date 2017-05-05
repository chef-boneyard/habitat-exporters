# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide single capability via CLI'
#

control 'cli_provides_single_provides' do
  title 'Provide single capability via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_single_provides/SPECS/core-netcat.spec') do
    its('content') { should match('Provides: capability') }
  end
end

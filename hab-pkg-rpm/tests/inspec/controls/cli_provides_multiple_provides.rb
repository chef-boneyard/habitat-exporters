# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide multiple capabilities via CLI'
#

control 'cli_provides_multiple_provides' do
  title 'Provide multiple capabilities via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_multiple_provides/SPECS/core-netcat.spec') do
    its('content') { should match('Provides: capability\nProvides: anothercapability') }
  end
end

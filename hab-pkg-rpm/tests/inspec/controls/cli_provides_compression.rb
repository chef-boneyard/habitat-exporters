# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide compression type via CLI'
#

control 'cli_provides_compression' do
  title 'Provide compression type via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_compression/SPECS/core-netcat.spec') do
    its('content') { should match('%define _binary_payload xz') }
  end
end

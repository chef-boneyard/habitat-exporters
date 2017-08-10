# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide single required package via CLI'
#

control 'cli_provides_single_requires' do
  title 'Provide single required package via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_single_requires/SPECS/core-netcat.spec') do
    its('content') { should match('Requires: somepackage') }
  end
end

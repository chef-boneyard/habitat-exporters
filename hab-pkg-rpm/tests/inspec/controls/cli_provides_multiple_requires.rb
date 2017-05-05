# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide multiple required packages via CLI'
#

control 'cli_provides_multiple_requires' do
  title 'Provide multiple required package via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_multiple_requires/SPECS/core-netcat.spec') do
    its('content') { should match('Requires: somepackage == 1.0.0\nRequires: someotherpackage < 1.0.0') }
  end
end

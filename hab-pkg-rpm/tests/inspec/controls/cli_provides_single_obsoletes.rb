# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide single obsoleted package via CLI'
#

control 'cli_provides_single_obsoletes' do
  title 'Provide single obsoleted package via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_single_obsoletes/SPECS/core-netcat.spec') do
    its('content') { should match('Obsoletes: obsoletedpackage') }
  end
end

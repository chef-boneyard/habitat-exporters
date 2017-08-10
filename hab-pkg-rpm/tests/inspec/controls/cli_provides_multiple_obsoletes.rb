# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide multiple obsoleted packages via CLI'
#

control 'cli_provides_multiple_obsoletes' do
  title 'Provide multiple obsoleted packages via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_multiple_obsoletes/SPECS/core-netcat.spec') do
    its('content') { should match('Obsoletes: obsoletedpackage == 1.0.0\nObsoletes: otherobsoletedpackage < 1.0.0') }
  end
end

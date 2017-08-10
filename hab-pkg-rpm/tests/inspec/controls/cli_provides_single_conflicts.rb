# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide single conflicting package via CLI'
#

control 'cli_provides_single_conflicts' do
  title 'Provide single conflicting package via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_single_conflicts/SPECS/core-netcat.spec') do
    its('content') { should match('Conflicts: conflictingpackage') }
  end
end

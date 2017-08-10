# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide multiple conflicting packages via CLI'
#

control 'cli_provides_multiple_conflicts' do
  title 'Provide multiple conflicting packages via CLI'
  describe file('/tmp/test-hab-pkg-rpm-cli_provides_multiple_conflicts/SPECS/core-netcat.spec') do
    its('content') { should match('Conflicts: conflictingpackage == 1.0.0\nConflicts: someotherconflictingpackage < 1.0.0') }
  end
end

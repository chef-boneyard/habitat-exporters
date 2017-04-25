# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide Debian archive filename via CLI'
#

control 'cli_provides_archive_name' do
  title 'Provide Debian archive filename via CLI'
  describe file('/tmp/test-hab-pkg-deb-cli_provides_archive_name/deb_archive_name') do
    its('content') { should match('bob.deb') }
  end
end

# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Provide section via CLI'
#

control 'cli_provides_section' do
  title 'Provide section via CLI'
  describe file('/tmp/test-hab-pkg-deb-cli_override_section/DEBIAN/control') do
    its('content') { should match('Section: tuba') }
  end
end

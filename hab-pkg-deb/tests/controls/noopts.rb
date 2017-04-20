# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Build package with no option overrides'
#

control 'noopts' do
  title 'Build package with no option overrides'
  describe file('/tmp/test-hab-pkg-deb-noopts/DEBIAN/control') do
    its('content') { should match('Package: core-busybox') }
    its('content') { should match(/Version: \d+\.\d+\.\d+$/) }
    its('content') { should match(/Iteration: \d{14}/) }
    its('content') { should match('License: gplv2') }
    its('content') { should match('Vendor: core') }
    its('content') { should match('Architecture: amd64') }
    its('content') { should match('Maintainer: The Habitat Maintainers <humans@habitat.sh>') }
    its('content') { should match(/Installed-Size: \d+$/) }
    its('content') { should match('Section: misc') }
    its('content') { should match('Priority: extra') }
    its('content') { should match('Homepage: upstream project\'s website or home page is not defined') }
    its('content') { should match('Description: busybox') }
  end

  describe file('/tmp/test-hab-pkg-deb-noopts/deb_archive_name') do
    its('content') { should match(/core-busybox_\d+\.\d+\.\d+-\d{14}_amd64\.deb/) }
  end
end

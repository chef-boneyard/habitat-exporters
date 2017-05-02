# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Build package with no option overrides'
#

control 'noopts' do
  title 'Build package with no option overrides'
  describe file('/tmp/test-hab-pkg-rpm-noopts/SPECS/core-busybox.spec') do
    its('content') { should match('Name: core-busybox') }
    its('content') { should match(/Version: \d+\.\d+\.\d+$/) }
    its('content') { should match(/Release: \d{14}$/) }
    its('content') { should match('Summary: busybox') }
    its('content') { should match('Group: default') }
    its('content') { should match('License: gplv2') }
    its('content') { should match('Vendor: core') }
    its('content') { should match('URL: upstream project\'s website or home page is not defined') }
    its('content') { should match('Packager: The Habitat Maintainers <humans@habitat.sh>') }
=begin
    its('content') { should match('Architecture: amd64') }
    its('content') { should match('Maintainer: The Habitat Maintainers <humans@habitat.sh>') }
    its('content') { should match(/Installed-Size: \d+$/) }
    its('content') { should match('Priority: extra') }
=end
  end

=begin
  describe file('/tmp/test-hab-pkg-rpm-noopts/rpm_name') do
    its('content') { should match(/core-busybox-\d+\.\d+\.\d+-\d{14}.x86_64\.rpm/) }
  end
=end
end

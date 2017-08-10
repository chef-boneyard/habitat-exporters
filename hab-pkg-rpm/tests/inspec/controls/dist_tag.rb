# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'Build package with no option overrides'
#

control 'dist_tag' do
  title 'Build package when CLI specifies --dist_tag'

  describe file('/tmp/test-hab-pkg-rpm-dist_tag/rpm_name') do
    its('content') { should match(/core-netcat-\d+\.\d+\.\d+-\d{14}.el7.x86_64\.rpm/) }
  end

  describe file('/tmp/test-hab-pkg-rpm-dist_tag/SPECS/core-netcat.spec') do
    its('content') { should match(/Release: \d{14}.el7/) }
  end
end

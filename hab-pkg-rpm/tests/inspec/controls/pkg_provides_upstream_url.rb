# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'package provides pkg_upstream_url in its plan.sh'
#

control 'pkg_provides_upstream_url' do
  title 'Package provides pkg_upstream_url in its plan.sh'
  describe file('/tmp/test-hab-pkg-rpm-pkg_provides_upstream_url/SPECS/core-netcat.spec') do
    its('content') { should match('URL: http://netcat.sourceforge.net/') }
  end
end

# encoding: utf-8
# copyright: 2017, The Authors
# license: All rights reserved
#
# title 'package provides pkg_upstream_url in its plan.sh'
#

control 'pkg_provides_upstream_url' do
  title 'Package provides pkg_upstream_url in its plan.sh'
  describe file('/tmp/test-hab-pkg-deb-pkg_provides_upstream_url/DEBIAN/control') do
    its('content') { should match('Homepage: http://netcat.sourceforge.net/') }
  end
end

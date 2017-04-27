# habitat .deb exporter

`hab-pkg-deb` allows you to export Debian packages from habitat.

## A fast introduction to Debian packaging
In its simplest form, a Debian package is an `ar` archive that contains

* A file tree for a piece of software,
* A directory called `DEBIAN` that contains
  * A file called `control`. The [control file]((https://www.debian.org/doc/debian-policy/ch-controlfields.html) contains information about the package, such as the package name, version, relationships with other packages.
  * Package install scripts, if any. The possible package install scripts are `preinst`, `postinst`, `prerm`, and `postrm`. In this context, `inst` indicates package install and `rm` indicates package removal.

[More basic details](https://www.debian.org/doc/manuals/debian-faq/ch-pkg_basics.en.html)

## Defaults
`hab pkg exec chef/hab-pkg-deb hab-pkg-deb <hab-pkg-origin>/<hab-pkg-name>`

will produce a Debian package named `<hab-pkg-origin>-<hab-pkg-name>\_$pkg\_version-$pkg\_release.deb`

where

* `$pkg_version` is as defined in `<hab-pkg-origin>/<hab-pkg-name>`'s plan
* `$pkg_release` is a timestamp taken when `<hab-pkg-origin>/<hab-pkg-name>` was built

The values generated for the exported package's control file are:

    Package: <hab-pkg-origin>-<hab-pkg-name>
    Version: $pkg_version-$pkg_release
    Vendor: $pkg_origin
    Architecture: <architecture according to dpkg>
    Maintainer: $pkg_maintainer if specified in <hab-pkg-origin>'s plan.sh; otherwise <hab-pkg-origin>
    Installed-Size: <package size computed by hab-pkg-deb>
    Section: misc
    Priority: extra
    Description: $pkg_description if set; otherwise <hab-pkg-name>

In addition,

* If `<hab-pkg-origin>/<hab-pkg-name>` has any of the package install scripts `postinst`, `postrm`, `preinst`, or `prerm` in its `bin` directory, `hab-pkg-deb` will include those scripts in the exported package.
* If `<hab-pkg-origin>/<hab-pkg-name>` has a [handlebars](https://www.npmjs.com/package/handlebars) template in `export/deb/control`, `hab-pkg-deb` will use this template to build the control file.

## Command-line options
### Overrides
The following command line options can be used to override default values in the control file:

    --archive=FILE      Filename of exported Debian package. Should end in .deb.
    --debname=NAME      Name of Debian package to be built. Used for Package field.
    --priority=PRIORITY Priority to be assigned to the Debian package. Used for Priority field.
    --section=SECTION   Section to be assigned to the Debian package. Used for Section field.

### Package installation scripts
The following command line options can be used to specify package installation scripts. Scripts thus specified will take precedence over any such scripts included in `<hab-pkg-origin>/<hab-pkg-name>`.

    --postinst=FILE     File name of script called after installation
    --postrm=FILE       File name of script called after removal
    --preinst=FILE      File name of script called before installation
    --prerm=FILE        File name of script called before removal

### Package Relationships
The following command line options can be used to specify relationships the exported package has with other packages:

    --conflicts=PKG     Package with which this conflicts
    --depends=PKG       Package on which this depends
    --provides=PKG      Name of facility this package provides
    --replaces=PKG      Package that this replaces

### Testing
The following command line option is used in testing only:

    --testname=TESTNAME Test name used to create a staging directory for examination

`hab-pkg-deb --testname=mytest ...` will stage the files to be packaged, including the control file, to the directory `/tmp/test-hab-pkg-deb-mytest` for future examination by tests; it will then exit without exporting a package.

## Undone

* Providing all control file fields from the command line. Users should be able to handle the common cases (e.g. including an epoch number or a distro name in their package version) by providing their own control file template with the package they wish to export and using `--archive` to explicitly name the exported .deb file. (Potential idea: allow users to provide their own [handlebars-cmd](https://www.npmjs.com/package/handlebars-cmd) command line to build their template.)
* Testing upgrade from a conventionally-built package to an exported Habitat one. This is beyond the scope of `hab-pkg-deb`.
* Omitted tests:
  * Verification of the help command.
  * Build a package whose plan does not set `pkg_maintainer`. (Need to habitat-ize something for the purpose.)
  * Build a package whose plan does not set `pkg_license`. (Need to habitat-ize something for the purpose.)

## Contributing

For information on contributing to this project see <https://github.com/chef/chef/blob/master/CONTRIBUTING.md>.

## License

```text
Copyright 2017 Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

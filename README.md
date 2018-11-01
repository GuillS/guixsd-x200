# guixsd-x200
My GuixSD configuration (config.scm) for a lenovo x200 tablet.

The pen and the touchscreen will be enabled with the udev rule from the config.scm file.

An alternative is the installation of the inputattach application:
```
$ guix package --install-from-file=./inputattach.scm
$ ...
$ inputattach --w8001 /dev/ttyS4
```

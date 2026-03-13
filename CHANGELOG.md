# Changelog

## Release v1.1.0 (2026-03-13)

### Minor compatibility breaks

* Replace `user` by `app_uid`, `app_gid` (default `1000`)
* Drop `data_directory` variable (redundant)

### Features

* Add `ca_bundle` variable to write and trust a custom CA bundle in the container

### Fix and enhancements

* Add `host.docker.internal` → host-gateway entry to container `/etc/hosts`
* Set `COLORTERM=truecolor` environment variable
* Set `enabled` default to `true`
* Refine variable descriptions, validators, and attribute ordering
* Remove redundant default values from examples and README

## Release v1.0.0 (2026-03-03)

Initial release

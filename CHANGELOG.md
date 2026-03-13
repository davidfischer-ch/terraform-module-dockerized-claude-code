# Changelog

## Release v1.2.1 (2026-03-14)

### Fix and enhancements

* Reorder variables to be consistent

## Release v1.2.0 (2026-03-13)

### Minor compatibility breaks

* The `cap_add` and `cap_drop` capabilities names are prefixed with `CAP_` for the Docker provider
* The `cap_add` and `cap_drop` variables are now validated against the exhaustive list of Linux capabilities

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

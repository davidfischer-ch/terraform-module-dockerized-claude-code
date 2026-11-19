# Changelog


## Release v1.3.2 (2026-11-19)

Diff: https://github.com/davidfischer-ch/terraform-module-dockerized-claude-code/compare/1.3.1...1.3.2

### Features

CI:

* Add CI: formatting, validation and the tests, in the GitHub workflow (with the newest providers and their minimums) and in the GitLab pipeline

### Fix and enhancements

Container:

* Pass `ALL` in `cap_add` and `cap_drop` to Docker as its wildcard instead of `CAP_ALL`
* Mount the `volume_name` and `from_container` entries of `extra_volumes` as declared, instead of an anonymous volume
* Hand the config directory over again, recursively, when `app_uid` or `app_gid` changes, whatever its path holds
    * The first apply after the upgrade runs `chown -R` over the config directory

Requirements:

* Require Terraform 1.17
* Require the Docker provider 4.7.0

Docs:

* Drop the `CAP_` prefix from the README's `cap_drop` examples, which the validation rejects
* Document `ALL` in `cap_add` and `cap_drop`
* Point the README and the examples at this release


## Release v1.3.1 (2026-11-14)

### Fix and enhancements

Container:

* Run a shell loop as PID 1 that reaps the processes the sessions orphan, which no session can stop

## Release v1.3.0 (2026-06-18)

### Minor compatibility breaks

* `model` default changed from `claude-sonnet-4-6` to `""` (Claude Code built-in default, currently the same model)
* `ANTHROPIC_MODEL` is no longer set when `model` is empty, letting Claude Code pick its own default

### Features

* Replace hardcoded model allowlist with a regex validation — any valid `claude-*` ID is accepted

## Release v1.2.2 (2026-03-15)

### Features

* Add `extra_devices` variable to expose host devices (e.g. Bluetooth HCI, USB) to the container
* Add `extra_groups` variable to add supplementary groups to the container user

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

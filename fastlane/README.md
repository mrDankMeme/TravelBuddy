fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint

### ios build_debug

```sh
[bundle exec] fastlane ios build_debug
```

Build Debug (simulator)

### ios archive_release

```sh
[bundle exec] fastlane ios archive_release
```

Archive Release (device)

### ios export_ipa

```sh
[bundle exec] fastlane ios export_ipa
```

Export IPA (ad-hoc)

### ios snapshots

```sh
[bundle exec] fastlane ios snapshots
```

Run UI snapshots via fastlane snapshot

### ios ci

```sh
[bundle exec] fastlane ios ci
```

CI lane

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

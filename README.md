# Commacd

A native macOS terminal, built from scratch with SwiftUI/AppKit on top of [SwiftTerm](https://github.com/migueldeicaza/SwiftTerm).

This is an open-source project with no signed/notarized releases — build it from source.

## Build from source

Requirements: Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
git clone https://github.com/D44NF/Commacd.git
cd Commacd
xcodegen generate
open Commacd.xcodeproj
```

Then build and run the `Commacd` scheme in Xcode (⌘R).

## License

GPLv3 — see [LICENSE](LICENSE). Third-party license notices are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

# Nightcord for iOS

This wrapper loads Discord Web in a native `WKWebView` and injects the web build of Nightcord.

## Requirements

- macOS with Xcode 15 or newer
- Apple ID or Apple Developer account
- Node.js and pnpm

## Build and export an IPA

From the repository root:

```sh
chmod +x ios/build-ios.sh
./ios/build-ios.sh
```

The generated IPA is written to `build/ipa/`.

## Signing limitation

This repository cannot generate a signed IPA on the current Windows environment because Xcode and Apple signing are macOS-only. With a free Apple ID, development signing can install the IPA on registered devices for a limited period. Distribution through a developer account can use Apple Developer or TestFlight workflows.

## Platform scope

Desktop-only plugins and Electron/native Discord APIs are not available. Web-compatible plugins may work; plugins marked `.desktop` or `.browser` targeting desktop APIs should be excluded or adapted.

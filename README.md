# Bitcoin Pet

Menu-bar macOS companion that keeps a draggable Bitcoin pet over other apps. Click the pet to expand a live BTC/USD quote, refreshed every second from Binance's public market endpoint.

## Download and install

1. Open the [latest release](https://github.com/juho0295-sys/BitcoinPet/releases/latest) and download `BitcoinPet-macOS-1.0.0-universal.zip`.
2. Open the ZIP and drag `Bitcoin Pet.app` into your Applications folder.
3. Launch it. The Bitcoin icon appears in the menu bar; click it to show or hide the pet.

Requires macOS 14 or later. The release is a universal app for Apple silicon and Intel Macs.

This build is ad-hoc signed and is not notarized with Apple, so macOS may show a security warning on first launch. Only open it if you trust this project. See [Apple's macOS distribution guidance](https://developer.apple.com/macos/distribution/) for how signing and notarization affect downloaded apps.

## Run from source

```sh
git clone https://github.com/juho0295-sys/BitcoinPet.git
cd BitcoinPet
swift run
```

To build a distributable universal app and ZIP locally:

```sh
zsh scripts/package-release.sh 1.0.0
```

Use the Bitcoin icon in the macOS menu bar to hide/show the pet, toggle always-on-top, or quit.

TradingView does not offer a public, unauthenticated real-time price API for this use case. The app therefore uses the commonly used BTCUSDT market feed for the live quote; the symbol and source are isolated in `FloatingPetView.swift` and can be changed to a licensed TradingView data source if you have access.

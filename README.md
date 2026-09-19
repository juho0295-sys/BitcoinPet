# Bitcoin Pet

Menu-bar macOS companion that keeps a draggable Bitcoin pet over other apps. Click the pet to expand a live BTC/USD quote, refreshed every second from Binance's public market endpoint.

## Run

```sh
cd /Users/juhomacbookair/Documents/Codex/BitcoinPet
swift run
```

Use the Bitcoin icon in the macOS menu bar to hide/show the pet, toggle always-on-top, or quit.

TradingView does not offer a public, unauthenticated real-time price API for this use case. The app therefore uses the commonly used BTCUSDT market feed for the live quote; the symbol and source are isolated in `FloatingPetView.swift` and can be changed to a licensed TradingView data source if you have access.

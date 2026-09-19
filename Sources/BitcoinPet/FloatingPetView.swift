import AppKit
import SwiftUI

struct FloatingPetView: View {
    @ObservedObject var controller: PetWindowController
    @StateObject private var quote = BitcoinQuoteStore()
    @State private var dragStartOrigin: NSPoint?

    var body: some View {
        VStack(spacing: 2) {
            if controller.isExpanded { quoteCard }

            ZStack(alignment: .bottomTrailing) {
                PetArtwork()
                    .scaledToFit()
                    .frame(width: controller.size, height: controller.size)
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 8)
                Circle()
                    .fill(quote.isConnected ? Color(red: 0.13, green: 0.91, blue: 0.67) : .orange)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                    .padding(20)
            }
            .contentShape(Rectangle())
            .onTapGesture { controller.toggleQuote() }
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .global)
                    .onChanged { value in
                        if dragStartOrigin == nil {
                            dragStartOrigin = controller.panelOrigin
                        }
                        guard let origin = dragStartOrigin else { return }
                        controller.movePanel(to: NSPoint(
                            x: origin.x + value.translation.width,
                            y: origin.y - value.translation.height
                        ))
                    }
                    .onEnded { _ in dragStartOrigin = nil }
            )
            .help("클릭해서 현재가 보기 · 드래그해서 이동")
            .accessibilityAddTraits(.isButton)
        }
        .frame(width: controller.isExpanded ? 190 : controller.size + 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .task { await quote.start() }
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "bitcoinsign.circle.fill").foregroundStyle(.orange)
                Text("BTC / USD").font(.system(size: 11, weight: .bold, design: .rounded))
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("LIVE").font(.system(size: 8, weight: .bold)).foregroundStyle(.green)
                    LiveClockText()
                }
            }
            .padding(.bottom, 1)
            Text(quote.formattedPrice)
                .font(.system(size: 21, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
                .padding(.bottom, 7)
            HStack {
                Label(quote.formattedChange, systemImage: quote.change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(quote.change >= 0 ? .green : .red)
                Spacer()
                Text("BINANCE · 1초 갱신").foregroundStyle(.secondary)
            }
            .font(.system(size: 9, weight: .medium))
        }
        .padding(15)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(.white.opacity(0.16), lineWidth: 1))
        .shadow(color: .black.opacity(0.22), radius: 14, y: 6)
        .padding(.horizontal, 5)
    }
}

private struct LiveClockText: View {
    @State private var now = Date()

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        Text(Self.formatter.string(from: now))
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(Color(red: 0.18, green: 0.43, blue: 0.95))
            .accessibilityLabel("현재 시각")
            .task {
                while !Task.isCancelled {
                    now = Date()
                    try? await Task.sleep(for: .seconds(1))
                }
            }
    }
}

/// `Image(name, bundle:)` only searches asset catalogs reliably in a bare Swift
/// executable. Load the packaged PNG by URL so it also works when launched via
/// `open` rather than as an .app bundle.
private struct PetArtwork: View {
    private static let image: NSImage? = {
        guard let url = Bundle.module.url(forResource: "bitcoin-pet", withExtension: "png") else { return nil }
        return NSImage(contentsOf: url)
    }()

    var body: some View {
        if let image = Self.image {
            Image(nsImage: image).resizable()
        } else {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(.orange)
        }
    }
}

@MainActor
final class BitcoinQuoteStore: ObservableObject {
    @Published private(set) var price = 0.0
    @Published private(set) var change = 0.0
    @Published private(set) var isConnected = false
    private var task: Task<Void, Never>?

    var formattedPrice: String {
        price == 0 ? "불러오는 중…" : price.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }
    var formattedChange: String { String(format: "%+.2f%%", change) }

    deinit { task?.cancel() }

    func start() async {
        guard task == nil else { return }
        task = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func refresh() async {
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/24hr?symbol=BTCUSDT") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let ticker = try JSONDecoder().decode(BinanceTicker.self, from: data)
            price = Double(ticker.lastPrice) ?? price
            change = Double(ticker.priceChangePercent) ?? 0
            isConnected = true
        } catch { isConnected = false }
    }
}

private struct BinanceTicker: Decodable {
    let lastPrice: String
    let priceChangePercent: String
}

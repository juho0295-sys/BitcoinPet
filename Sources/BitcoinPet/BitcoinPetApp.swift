import AppKit
import Combine
import SwiftUI

@main
struct BitcoinPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Bitcoin Pet", systemImage: "bitcoinsign.circle.fill") {
            MenuContent(controller: appDelegate.controller)
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let controller = PetWindowController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // A regular activation policy gives the app its own Dock icon while the
        // menu-bar control remains available.
        NSApp.setActivationPolicy(.regular)
        controller.showPet()
    }
}

@MainActor
final class PetWindowController: NSObject, ObservableObject {
    @Published var isVisible = true
    @Published var isPinned = true
    @Published var isExpanded = false
    /// Big enough to remain legible on a 5K desktop, without covering a working window.
    @Published var size: CGFloat = 50
    private var panel: NSPanel?

    func showPet() {
        if panel == nil { makePanel() }
        panel?.orderFrontRegardless()
        isVisible = true
    }

    func hidePet() {
        panel?.orderOut(nil)
        isVisible = false
    }

    func togglePet() { isVisible ? hidePet() : showPet() }

    func toggleQuote() {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
            isExpanded.toggle()
        }
        resizePanel()
    }

    var panelOrigin: NSPoint? { panel?.frame.origin }

    func movePanel(to origin: NSPoint) {
        panel?.setFrameOrigin(origin)
    }

    func setPinned(_ pinned: Bool) {
        isPinned = pinned
        panel?.level = pinned ? .floating : .normal
    }

    private func makePanel() {
        let pet = FloatingPetView(controller: self)
        let host = NSHostingView(rootView: pet)
        let screen = NSScreen.main?.visibleFrame ?? .init(x: 0, y: 0, width: 1440, height: 900)
        let frame = NSRect(
            x: screen.maxX - panelWidth - 34,
            y: screen.minY + 80,
            width: panelWidth,
            height: panelHeight
        )
        let newPanel = NSPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        newPanel.contentView = host
        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.hasShadow = false
        newPanel.level = .floating
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        newPanel.isMovableByWindowBackground = true
        newPanel.hidesOnDeactivate = false
        newPanel.becomesKeyOnlyIfNeeded = true
        panel = newPanel
    }

    private var panelWidth: CGFloat { isExpanded ? 200 : size + 24 }
    private var panelHeight: CGFloat { size + (isExpanded ? 152 : 28) }

    /// Keep the pet's feet in the same spot while the quote card grows above it.
    private func resizePanel() {
        guard let panel else { return }
        let old = panel.frame
        let visibleFrame = NSScreen.screens.first(where: { $0.frame.intersects(old) })?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? .init(x: 0, y: 0, width: 1440, height: 900)
        let rightEdge = min(old.maxX, visibleFrame.maxX - 34)
        let leftEdge = max(visibleFrame.minX + 34, rightEdge - panelWidth)
        let newFrame = NSRect(x: leftEdge, y: old.minY, width: panelWidth, height: panelHeight)
        panel.setFrame(newFrame, display: true, animate: true)
    }
}

private struct MenuContent: View {
    @ObservedObject var controller: PetWindowController

    var body: some View {
        Button(controller.isVisible ? "펫 숨기기" : "펫 보이기") { controller.togglePet() }
        Toggle("항상 화면 위", isOn: Binding(get: { controller.isPinned }, set: controller.setPinned))
        Divider()
        Button("종료") { NSApp.terminate(nil) }
    }
}

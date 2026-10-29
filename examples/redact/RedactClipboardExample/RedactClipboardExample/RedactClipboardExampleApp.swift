import SwiftUI

@main
struct RedactClipboardExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 520, minHeight: 480)
                #endif
        }
    }
}

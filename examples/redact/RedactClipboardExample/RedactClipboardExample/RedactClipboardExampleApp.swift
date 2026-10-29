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
        #if os(macOS)
        // Room for the text and the report side by side.
        .defaultSize(width: 900, height: 600)
        #endif
    }
}

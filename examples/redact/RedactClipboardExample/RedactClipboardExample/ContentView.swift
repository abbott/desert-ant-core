import Redact
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// Paste text in, get redacted text out, ready to paste into an LLM. Redact
// swaps the personal data for numbered placeholders like [EMAIL_1], on the
// device. With "Copy automatically" on, every result goes straight to the
// clipboard, which also replaces the original you pasted from it. The whole SDK
// surface used here is `Redact()`, `download()` and `redaction(of:options:)`.

struct ContentView: View {
    @State private var input = ""
    @State private var result: Redaction?
    @State private var resultSource = ""         // the input `result` was computed from
    @State private var resultRedactsURLs = true  // and the URL setting it was computed with
    @State private var status = "Loading model…"
    @State private var statusIsError = false
    @State private var redactTask: Task<Void, Never>?
    @AppStorage("copyAutomatically") private var copyAutomatically = true
    // Redact masks every http(s), ftp and www URL with a pattern, whatever the
    // host, so logs and configs full of public URLs come back mostly
    // placeholders. Off keeps URLs, including any personal data inside them.
    @AppStorage("redactURLs") private var redactURLs = true

    // Held in @State so the loaded model survives the view being re-created.
    @State private var redact = Redact()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Original").font(.headline)
                    Spacer()
                    // PasteButton reads the clipboard without the iOS paste prompt.
                    PasteButton(payloadType: String.self) { strings in
                        if let text = strings.first { input = text }
                    }
                    Button("Clear", systemImage: "xmark.circle") { input = "" }
                        .disabled(input.isEmpty)
                }
                editor

                HStack {
                    Text("Redacted").font(.headline)
                    Spacer()
                    Button("Copy", systemImage: "doc.on.doc") { copyResult() }
                        .disabled(!isCurrent)
                }
                output

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Copy automatically", isOn: $copyAutomatically)
                    Toggle("Redact URLs", isOn: $redactURLs)
                }
                .toggleStyle(.switch)

                Text(status)
                    .font(.footnote)
                    .foregroundStyle(statusIsError ? Color.red : .secondary)
            }
            .padding()
            .navigationTitle("Redact")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .task { await loadModel() }
        .onChange(of: input) { schedule() }
        .onChange(of: redactURLs) { schedule() }
    }

    // MARK: Sections

    private var editor: some View {
        TextEditor(text: $input)
            .font(.body.monospaced())
            .scrollContentBackground(.hidden)
            .padding(6)
            .frame(minHeight: 140)
            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                if input.isEmpty {
                    Text("Paste text that may contain personal data.")
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .allowsHitTesting(false)
                }
            }
    }

    private var output: some View {
        ScrollView {
            Text(result?.redactedText ?? "")
                .font(.body.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
        }
        .frame(minHeight: 140)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .opacity(isCurrent ? 1 : 0.5)
    }

    // MARK: Redacting (debounced, drops superseded runs)

    /// Whether the shown result belongs to the text in the editor and the
    /// current settings, so Copy never hands out a stale redaction.
    private var isCurrent: Bool {
        result != nil && resultSource == input && resultRedactsURLs == redactURLs
    }

    private func loadModel() async {
        do {
            try await redact.download()
            if input.isEmpty { status = "Ready. Paste text to redact it." }
        } catch {
            status = "Couldn't load the model: \(error.localizedDescription)"
            statusIsError = true
        }
    }

    private func schedule() {
        redactTask?.cancel()
        redactTask = Task {
            try? await Task.sleep(for: .milliseconds(200))
            if Task.isCancelled { return }
            await redactNow()
        }
    }

    private func redactNow() async {
        let text = input
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            result = nil
            status = "Paste text to redact it."
            statusIsError = false
            return
        }
        let redactsURLs = redactURLs
        status = "Redacting…"
        do {
            let r = try await redact.redaction(of: text, options: redactsURLs ? .init() : .keepingURLs)
            guard !Task.isCancelled, text == input, redactsURLs == redactURLs else { return }
            result = r
            resultSource = text
            resultRedactsURLs = redactsURLs
            statusIsError = false
            let found = r.items.isEmpty ? "No personal data found"
                : r.items.count == 1 ? "1 item redacted" : "\(r.items.count) items redacted"
            if copyAutomatically {
                Clipboard.copy(r.redactedText)
                status = "\(found). Copied to the clipboard."
            } else {
                status = "\(found)."
            }
        } catch {
            result = nil
            status = "Redaction failed: \(error.localizedDescription)"
            statusIsError = true
        }
    }

    private func copyResult() {
        guard isCurrent, let result else { return }
        Clipboard.copy(result.redactedText)
        status = "Copied to the clipboard."
        statusIsError = false
    }
}

private enum Clipboard {
    static func copy(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}

#Preview {
    ContentView()
}

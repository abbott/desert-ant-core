# Redact Clipboard Example

A small SwiftUI app for macOS and iOS: paste text in, and Redact masks the personal data in it on the device and puts the redacted text on the clipboard, ready to paste into an LLM.

Names, emails, phone numbers, cards and the other [labels](../../../docs/models/redact.md#labels) come back as numbered placeholders like `[EMAIL_1]`.

## Run

Open `RedactClipboardExample.xcodeproj` in Xcode, choose My Mac or an iOS simulator, and press Run. To run on an iPhone or iPad, choose your team under Signing & Capabilities first.

The project builds Redact from this checkout. The first redaction downloads the pinned Core ML model to the app cache. Later runs use the cached model offline.

## Use

1. Press **Paste**, or type into the top box. Redact runs as soon as the text changes.
2. With **Copy automatically** on (the default), each result goes straight to the clipboard. That also replaces the original text you pasted from it.
3. With it off, press **Copy** when you want the redacted text.
4. Turn **Redact URLs** off to keep links. Redact masks every `http`, `https`, `ftp` and `www` URL with a pattern, whatever the host, so logs and configs full of public URLs, like package mirrors, come back mostly placeholders. With it off, personal data inside a URL, like a token or an email in a query string, stays too.

**Copy** is disabled while a new result is being computed, so it never copies a stale redaction.

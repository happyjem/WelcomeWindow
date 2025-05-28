//
//  TXTDocument.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//


import SwiftUI
import UniformTypeIdentifiers

/// Minimal in-app plain-text document.
final class TXTDocument: NSDocument, ObservableObject {

    @Published var text = ""

    override class var autosavesInPlace: Bool { true }

    override func read(from data: Data, ofType typeName: String) throws {
        text = String(decoding: data, as: UTF8.self)
    }

    override func data(ofType typeName: String) throws -> Data {
        text.data(using: .utf8) ?? Data()
    }

    override func makeWindowControllers() {
        let root = TXTEditorView(document: self)          // 👈  SwiftUI wrapper
        let window = NSWindow(contentViewController: NSHostingController(rootView: root))
        addWindowController(NSWindowController(window: window))
    }
}

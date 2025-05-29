//
//  NSDocumentController+Extensions.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//

import AppKit
import UniformTypeIdentifiers

/// Utility methods for opening and saving project documents using custom dialog configurations.
extension NSDocumentController {

    /// Presents a save dialog to create a new document using the specified configuration and initial file content.
    ///
    /// This method displays an `NSSavePanel` configured by the given `DocumentSaveDialogConfiguration`.
    /// If user completes the dialog, `defaultContentProvider` closure is called to generate the file's initial content,
    /// which is then written to disk. The document is then opened via `NSDocumentController`.
    ///
    /// - Parameters:
    ///   - configuration: Configuration for customizing the save panel (title, allowed UTT,, default name, etc.).
    ///   - defaultContentProvider: A closure that returns the initial new file contents. Must return `Data`.
    ///   - onDialogPresented: Called after the dialog is presented (on the main thread).
    ///   - onCompletion: Called if the document is successfully created and opened.
    ///   - onCancel: Called if the user cancels the dialog or an error occurs during file creation or opening.
    @MainActor
    public func createNewDocumentWithDialog(
        configuration: DocumentSaveDialogConfiguration = DocumentSaveDialogConfiguration(),
        defaultContentProvider: () throws -> Data,
        onDialogPresented: @escaping () -> Void = {},
        onCompletion: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        let panel = NSSavePanel()
        panel.prompt = configuration.prompt
        panel.nameFieldLabel = configuration.nameFieldLabel
        panel.nameFieldStringValue = configuration.defaultFileName
        panel.canCreateDirectories = true
        panel.allowedContentTypes = configuration.allowedContentTypes
        panel.title = configuration.title
        panel.level = .modalPanel
        panel.directoryURL = configuration.directoryURL

        DispatchQueue.main.async { onDialogPresented() }

        let response = panel.runModal()
        guard response == .OK, let fileURL = panel.url else {
            onCancel()
            return
        }

        do {
            let content = try defaultContentProvider()
            try content.write(to: fileURL)
            self.openDocument(at: fileURL, onCompletion: onCompletion, onError: { _ in onCancel() })
        } catch {
            NSAlert(error: error).runModal()
            onCancel()
        }
    }

    /// Presents a save dialog to create a new, empty document using the specified configuration.
    ///
    /// This is a convenience overload of `createNewDocumentWithDialog(...)` that writes an empty file (`Data()`)
    /// as the initial content. Use this when no initial file data is required (e.g., a blank or placeholder file).
    ///
    /// - Parameters:
    ///   - configuration: Configuration for customizing the save panel (title, content types, default name, etc.).
    ///   - onDialogPresented: Called after the dialog is presented (on the main thread).
    ///   - onCompletion: Called if the document is successfully created and opened.
    ///   - onCancel: Called if the user cancels the dialog or if an error occurs during file creation or opening.
    @MainActor
    public func createNewDocumentWithDialog(
        configuration: DocumentSaveDialogConfiguration = DocumentSaveDialogConfiguration(),
        onDialogPresented: @escaping () -> Void = {},
        onCompletion: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        createNewDocumentWithDialog(
            configuration: configuration,
            defaultContentProvider: { Data() },
            onDialogPresented: onDialogPresented,
            onCompletion: onCompletion,
            onCancel: onCancel
        )
    }

    /// Presents an open dialog to choose a document using the specified configuration.
    ///
    /// - Parameters:
    ///   - configuration: Configuration for customizing the open panel. Defaults to a plain text file configuration.
    ///   - onDialogPresented: Called after the dialog is presented.
    ///   - onCompletion: Called if the document is successfully opened.
    ///   - onCancel: Called if the user cancels or an error occurs.
    @MainActor
    public func openDocumentWithDialog(
        configuration: DocumentOpenDialogConfiguration = DocumentOpenDialogConfiguration(),
        onDialogPresented: @escaping () -> Void = {},
        onCompletion: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        let panel = NSOpenPanel()
        panel.title = configuration.title
        panel.canChooseFiles = configuration.canChooseFiles
        panel.canChooseDirectories = configuration.canChooseDirectories
        panel.allowedContentTypes = configuration.allowedContentTypes
        panel.directoryURL = configuration.directoryURL
        panel.level = .modalPanel

        DispatchQueue.main.async { onDialogPresented() }

        let result = panel.runModal()
        guard result == .OK, let selectedURL = panel.url else {
            onCancel()
            return
        }

        self.openDocument(at: selectedURL, onCompletion: onCompletion, onError: { _ in onCancel() })
    }

    /// Opens a document at the specified URL and optionally tracks it in recent projects.
    ///
    /// - Parameters:
    ///   - url: The URL of the document to open.
    ///   - onCompletion: Called if the document is successfully opened.
    ///   - onError: Called if an error occurs while opening the document. Default is an empty closure.
    @MainActor
    public func openDocument(
        at url: URL,
        onCompletion: @escaping () -> Void = {},
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        let accessGranted = RecentsStore.beginAccessing(url)
        openDocument(withContentsOf: url, display: true) { _, _, error in
            defer { if accessGranted { RecentsStore.endAccessing(url) } }
            if let error {
                NSAlert(error: error).runModal()
                onError(error)
            } else {
                NSApp.activate(ignoringOtherApps: true)
                RecentsStore.documentOpened(at: url)
                onCompletion()
            }
        }
    }
}

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

    /// Displays a save dialog for **single, flat-file** document types
    /// (e.g. `MyNote.txt`, `Foo.circuitproj`).
    /// The selected URL is passed to `NSDocument.write(…)`, then the document
    /// is opened via `openDocument(at:)`.
    ///
    /// - Parameters:
    ///   - configuration:   Appearance & UTI filter for the save panel.
    ///   - onDialogPresented: Callback fired *after* the sheet/panel is shown.
    ///   - onCompletion:    Invoked when the document window successfully opens.
    ///   - onCancel:        Invoked if the user cancels or an error occurs.
    @MainActor
    public func createFileDocumentWithDialog(
        configuration: DocumentSaveDialogConfiguration = .init(),
        onDialogPresented: @escaping () -> Void = {},
        onCompletion: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        _createDocument(
            mode: .file,
            configuration: configuration,
            onDialogPresented: onDialogPresented,
            onCompletion: onCompletion,
            onCancel: onCancel
        )
    }

    /// Displays a save dialog that asks for a **folder name** and then
    /// creates a *package* project inside that folder:
    ///
    /// ```text
    /// <Folder>/
    /// ├─ <Folder>.<ext>   ← primary file written by `write(…)`
    /// └─ <assets…>
    /// ```
    ///
    /// - Important: Pass a `DocumentSaveDialogConfiguration` whose
    ///   `defaultFileType` matches the document subclass *and* whose
    ///   `defaultFileName` is **folder‐style** (without the extension).
    @MainActor
    public func createFolderDocumentWithDialog(
        configuration: DocumentSaveDialogConfiguration,
        onDialogPresented: @escaping () -> Void = {},
        onCompletion: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        _createDocument(
            mode: .folder,
            configuration: configuration,
            onDialogPresented: onDialogPresented,
            onCompletion: onCompletion,
            onCancel: onCancel
        )
    }

    // MARK: - Private shared implementation
    // ─────────────────────────────────────────────────────────────────────
    private enum SaveMode { case file, folder }

    /// Internal helper that contains 100 % of the common logic.
    @MainActor
    private func _createDocument(
        mode: SaveMode,
        configuration: DocumentSaveDialogConfiguration,
        onDialogPresented: @escaping () -> Void,
        onCompletion: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {

        // 1. Configure NSSavePanel ------------------------------------------------
        let panel = NSSavePanel()
        panel.prompt               = configuration.prompt
        panel.title                = configuration.title
        panel.nameFieldLabel       = configuration.nameFieldLabel
        panel.canCreateDirectories = true
        panel.directoryURL         = configuration.directoryURL
        panel.level                = .modalPanel
        panel.treatsFilePackagesAsDirectories = true

        switch mode {
        case .file:
            panel.nameFieldStringValue = configuration.defaultFileName
            panel.allowedContentTypes  = configuration.allowedContentTypes
        case .folder:
            panel.nameFieldStringValue =
                URL(fileURLWithPath: configuration.defaultFileName)
                    .deletingPathExtension().lastPathComponent
            panel.allowedContentTypes  = []                // treat as folder
        }

        DispatchQueue.main.async { onDialogPresented() }
        guard panel.runModal() == .OK,
              let baseURL = panel.url else { onCancel(); return }

        // 2. Derive the final document file URL ----------------------------------
        let ext      = configuration.defaultFileType.preferredFilenameExtension ?? "file"
        let finalURL = (mode == .folder)
            ? baseURL.appendingPathComponent("\(baseURL.lastPathComponent).\(ext)")
            : baseURL

        // 3. Create, write, and open the NSDocument ------------------------------
        do {
            let document  = try makeUntitledDocument(ofType: configuration.defaultFileType.identifier)
            document.fileURL = finalURL

            try document.write(
                to: finalURL,
                ofType: configuration.defaultFileType.identifier,
                for: .saveOperation,
                originalContentsURL: nil
            )

            openDocument(
                at: finalURL,
                onCompletion: onCompletion,
                onError: { error in
                    NSAlert(error: error).runModal()
                    onCancel()
                }
            )
        } catch {
            NSAlert(error: error).runModal()
            onCancel()
        }
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
            if let error {
                if accessGranted {
                    RecentsStore.endAccessing(url)
                }
                NSAlert(error: error).runModal()
                onError(error)
            } else {
                RecentsStore.documentOpened(at: url)
                NSApp.activate(ignoringOtherApps: true)
                onCompletion()
            }
        }
    }
}

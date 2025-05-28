//
//  NSDocumentController+ProjectDocumentHandler.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//

import AppKit
import UniformTypeIdentifiers

extension NSDocumentController {

    @MainActor
    public func createNewDocumentWithDialog(
        configuration: DocumentSaveDialogConfiguration = DocumentSaveDialogConfiguration(),
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
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            self.openDocument(at: fileURL, onCompletion: onCompletion, onError: { _ in onCancel() })
        } catch {
            NSAlert(error: error).runModal()
            onCancel()
        }
    }

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


    @MainActor
    public func openDocument(
        at url: URL,
        onCompletion: @escaping () -> Void,
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        
        let accessed = RecentProjectsStore.beginAccessing(url)
        openDocument(withContentsOf: url, display: true) { _, _, error in
            if let error {
                NSAlert(error: error).runModal()
                onError(error)
            } else {
                // Log to recent projects
                RecentProjectsStore.documentOpened(at: url)
                
                NSApp.activate(ignoringOtherApps: true)
                onCompletion()
            }
        }
    }
}

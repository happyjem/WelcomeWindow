//
//  NSDocumentt.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//

import AppKit

extension NSDocumentController {
    public func openDocument(
        configuration: DocumentOpenDialogConfiguration,
        onCompletion: @escaping (NSDocument?, Bool) -> Void,
        onCancel: @escaping () -> Void
    ) {
        let dialog = NSOpenPanel()
        dialog.title = configuration.title
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = configuration.canChooseDirectories
        dialog.allowedContentTypes = configuration.allowedContentTypes

        dialog.begin { result in
            guard result == .OK, let selectedURL = dialog.url else {
                onCancel()
                return
            }

            let resolvedURL = configuration.transformURL?(selectedURL) ?? selectedURL

            self.openDocument(withContentsOf: resolvedURL, display: true) { document, wasAlreadyOpen, error in
                if let error {
                    NSAlert(error: error).runModal()
                    onCancel()
                    return
                }

                guard let document else {
                    let alert = NSAlert()
                    alert.messageText = "Failed to open document"
                    alert.informativeText = resolvedURL.lastPathComponent
                    alert.runModal()
                    onCancel()
                    return
                }

                onCompletion(document, wasAlreadyOpen)
            }
        }
    }
}

//
//  NSDocumentController+ProjectDocumentHandler.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//

import AppKit

extension NSDocumentController: ProjectDocumentHandler {

    /// Bridge to the document-based API.
    @MainActor
    public func openDocument(at url: URL?, completion: @escaping () -> Void) {
        if let url {
            openDocument(withContentsOf: url, display: true) { _, _, _ in
                completion()
            }
        } else {
            let config = DocumentOpenDialogConfiguration(
                title: "Open Text File",
                allowedContentTypes: [.plainText]
            )

            openDocument(
                configuration: config,
                onCompletion: { _, _ in
                    completion()
                },
                onCancel: {
                    
                }
            )
        }
    }

    /// Create-new maps straight to `newDocument`.
    @MainActor
    public func createNewDocument() {
        newDocument(nil)
    }
}

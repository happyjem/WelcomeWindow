//
//  TXTDocumentController.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//
import Cocoa
import UniformTypeIdentifiers

final class TXTDocumentController: NSDocumentController {

    override func newDocument(_ sender: Any?) {
        print("✅ TXTDocumentController.newDocument called")

        let panel = NSSavePanel()
        panel.prompt = "Create Text File"
        panel.nameFieldLabel = "File Name:"
        panel.nameFieldStringValue = "NewTextFile.txt"
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [UTType.plainText]
        panel.title = "Create a New Text File"
        panel.level = .modalPanel
        panel.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        // 🔄 Synchronous – blocks until user finishes
        let response = panel.runModal()
        guard response == .OK, let fileURL = panel.url else {
            return
        }

        do {
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            self.openDocument(withContentsOf: fileURL, display: true) { _, _, error in
                if let error {
                    NSAlert(error: error).runModal()
                }
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }


    override func openDocument(_ sender: Any?) {
        openTextFile()
    }

    private func openTextFile() {
        let config = DocumentOpenDialogConfiguration(
            title: "Open Text File",
            allowedContentTypes: [.plainText],
            canChooseDirectories: false
        )

        openDocument(
            configuration: config,
            onCompletion: { document, wasAlreadyOpen in
                print("✅ Document opened: \(String(describing: document)) (already open: \(wasAlreadyOpen))")
            },
            onCancel: {
                print("❌ User canceled open text file dialog")
            }
        )
    }

}

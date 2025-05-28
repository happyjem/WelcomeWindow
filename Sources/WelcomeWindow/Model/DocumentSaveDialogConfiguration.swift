//
//  DocumentSaveDialogConfiguration.swift
//  CodeEditWelcomeWindow
//
//  Created by Giorgi Tchelidze on 25.05.25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A configuration struct for presenting a save document dialog.
public struct DocumentSaveDialogConfiguration {

    /// The prompt displayed on the save dialog (e.g., the action button title).
    public var prompt: String

    /// The label for the name input field.
    public var nameFieldLabel: String

    /// The default name of the file being saved.
    public var defaultFileName: String

    /// The content types that the file can be saved as.
    public var allowedContentTypes: [UTType]

    /// The title of the save dialog window.
    public var title: String

    /// The initial directory URL shown in the dialog.
    public var directoryURL: URL?

    /// Creates a new `DocumentSaveDialogConfiguration` with the given parameters.
    ///
    /// - Parameters:
    ///   - prompt: The prompt shown in the dialog. Default is `"Create Document"`.
    ///   - nameFieldLabel: The label for the name field. Default is `"File Name:"`.
    ///   - defaultFileName: The default file name. Default is `"Untitled"`.
    ///   - allowedContentTypes: The allowed content types for the saved file. Default is `[.plainText]`.
    ///   - title: The title of the save dialog window. Default is `"Create a New Document"`.
    ///   - directoryURL: The default directory URL. Default is the user's document directory.
    public init(
        prompt: String = "Create Document",
        nameFieldLabel: String = "File Name:",
        defaultFileName: String = "Untitled",
        allowedContentTypes: [UTType] = [UTType.plainText],
        title: String = "Create a New Document",
        directoryURL: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    ) {
        self.prompt = prompt
        self.nameFieldLabel = nameFieldLabel
        self.defaultFileName = defaultFileName
        self.allowedContentTypes = allowedContentTypes
        self.title = title
        self.directoryURL = directoryURL
    }
}

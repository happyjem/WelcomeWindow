//
//  DocumentSaveDialogConfiguration.swift
//  CodeEditWelcomeWindow
//
//  Created by Giorgi Tchelidze on 25.05.25.
//
import SwiftUI
import UniformTypeIdentifiers

public struct DocumentSaveDialogConfiguration {
    public var prompt: String
    public var nameFieldLabel: String
    public var defaultFileName: String
    public var allowedContentTypes: [UTType]
    public var title: String
    public var directoryURL: URL?

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

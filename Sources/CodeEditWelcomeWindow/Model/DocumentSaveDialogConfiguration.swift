//
//  DocumentSaveDialogConfiguration.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//
import UniformTypeIdentifiers
import SwiftUI

public struct DocumentSaveDialogConfiguration {
    public let title: String
    public let prompt: String
    public let defaultFilename: String
    public let allowedContentTypes: [UTType]

    public init(
        title: String,
        prompt: String,
        defaultFilename: String,
        allowedContentTypes: [UTType]
    ) {
        self.title = title
        self.prompt = prompt
        self.defaultFilename = defaultFilename
        self.allowedContentTypes = allowedContentTypes
    }
}

//
//  DocumentOpenDialogConfiguration.swift
//  CodeEditWelcomeWindow
//
//  Created by Giorgi Tchelidze on 25.05.25.
//

import SwiftUI
import UniformTypeIdentifiers

public struct DocumentOpenDialogConfiguration {
    public var title: String
    public var allowedContentTypes: [UTType]
    public var directoryURL: URL?

    public init(
        title: String = "Open Document",
        allowedContentTypes: [UTType] = [UTType.plainText],
        directoryURL: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    ) {
        self.title = title
        self.allowedContentTypes = allowedContentTypes
        self.directoryURL = directoryURL
    }
}

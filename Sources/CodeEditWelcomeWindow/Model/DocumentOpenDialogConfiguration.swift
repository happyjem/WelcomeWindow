//
//  DocumentOpenDialogConfiguration.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//
import UniformTypeIdentifiers
import SwiftUI

public struct DocumentOpenDialogConfiguration {
    public let title: String
    public let allowedContentTypes: [UTType]
    public let canChooseDirectories: Bool
    public let transformURL: ((URL) -> URL)?

    public init(
        title: String,
        allowedContentTypes: [UTType],
        canChooseDirectories: Bool = false,
        transformURL: ((URL) -> URL)? = nil
    ) {
        self.title = title
        self.allowedContentTypes = allowedContentTypes
        self.canChooseDirectories = canChooseDirectories
        self.transformURL = transformURL
    }
}

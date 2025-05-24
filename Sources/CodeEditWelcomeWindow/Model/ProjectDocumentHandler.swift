//
//  ProjectDocumentHandler.swift
//  Tests
//
//  Created by Giorgi Tchelidze on 23.05.25.
//
import SwiftUI

@MainActor
public protocol ProjectDocumentHandler {
    func openDocument(at url: URL?, completion: @escaping () -> Void)
    func createNewDocument()
}

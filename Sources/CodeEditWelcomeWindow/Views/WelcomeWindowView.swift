//
//  WelcomeWindowView.swift
//  CodeEditModules/WelcomeModule
//
//  Created by Ziyuan Zhao on 2022/3/18.
//

import SwiftUI
import AppKit

public struct WelcomeWindowView: View {

    private let documentHandler: ProjectDocumentHandler
    private let dismissWindow: () -> Void

    public init(
        documentHandler: ProjectDocumentHandler,
        dismissWindow: @escaping () -> Void
    ) {
        self.documentHandler = documentHandler
        self.dismissWindow = dismissWindow
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            WelcomeView(
                documentHandler: documentHandler,
                dismissWindow: dismissWindow
            )
            RecentProjectsListView(
                documentHandler: documentHandler,
                dismissWindow: dismissWindow
            )
            .frame(width: 280)
        }
        .edgesIgnoringSafeArea(.top)
        .onDrop(of: [.fileURL], isTargeted: .constant(true)) { providers in
            NSApp.activate(ignoringOtherApps: true)
            providers.forEach {
                _ = $0.loadDataRepresentation(for: .fileURL) { data, _ in
                    if let data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        Task {
                            await documentHandler.openDocument(at: url) {
                                Task { @MainActor in
                                    dismissWindow()
                                }
                            }
                        }
                    }
                }
            }
            return true
        }
    }
}

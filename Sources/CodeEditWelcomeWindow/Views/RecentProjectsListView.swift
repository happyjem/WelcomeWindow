//
//  RecentProjectsListView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/02/2023.
//

import SwiftUI
import CoreSpotlight
import AppKit

public struct RecentProjectsListView: View {
    
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selection: Set<URL>
    @State private var recentProjects: [URL]

    private let dismissWindow: () -> Void

    public init(dismissWindow: @escaping () -> Void) {
        self.dismissWindow = dismissWindow
        let urls = RecentProjectsStore.recentProjectURLs()
        self._recentProjects = State(initialValue: urls)
        self._selection = State(initialValue: Set(urls.prefix(1)))
    }

    private var listEmptyView: some View {
        VStack {
            Spacer()
            Text(NSLocalizedString("No Recent Projects", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    public var body: some View {
        List(recentProjects, id: \.self, selection: $selection) { project in
            RecentProjectListItem(projectPath: project)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .contextMenu(forSelectionType: URL.self) { items in
            if !items.isEmpty {
                Button("Show in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting(Array(items))
                }

                Button("Copy path\(items.count > 1 ? "s" : "")") {
                    let pasteBoard = NSPasteboard.general
                    pasteBoard.clearContents()
                    pasteBoard.writeObjects(selection.map(\.relativePath) as [NSString])
                }

                Button("Remove from Recents") {
                    removeRecentProjects()
                }
            }
        } primaryAction: { items in
            for url in items {

                NSDocumentController.shared.openDocument(at: url) {
                    dismissWindow()
                }
            }
        }
        .onCopyCommand {
            selection.map { NSItemProvider(object: $0.path(percentEncoded: false) as NSString) }
        }
        .onDeleteCommand {
            removeRecentProjects()
        }
        .background {
            if self.colorScheme == .dark {
                Color(.black).opacity(0.075)
                    .background(.thickMaterial)
            } else {
                Color(.white).opacity(0.6)
                    .background(.regularMaterial)
            }
        }
        .background {
            Button("") {
                selection.forEach { url in
                    NSDocumentController.shared.openDocument(at: url) {
                        dismissWindow()
                    }
                }
            }
            .keyboardShortcut(.defaultAction)
            .hidden()
        }
        .overlay {
            if recentProjects.isEmpty {
                listEmptyView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: RecentProjectsStore.didUpdateNotification)) { _ in
            updateRecentProjects()
        }
    }

    private func removeRecentProjects() {
        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
    }

    private func updateRecentProjects() {
        recentProjects = RecentProjectsStore.recentProjectURLs()
    }
}

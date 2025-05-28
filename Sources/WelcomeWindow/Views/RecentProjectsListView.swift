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

    @Environment(\.colorScheme)
    private var colorScheme

    @Binding private var recentProjects: [URL]
    @Binding private var selection: Set<URL>

    @FocusState.Binding private var focusedField: FocusTarget?
    private let dismissWindow: () -> Void

    public init(
        recentProjects: Binding<[URL]>,
        selection: Binding<Set<URL>>,
        focusedField: FocusState<FocusTarget?>.Binding,
        dismissWindow: @escaping () -> Void
    ) {
        self._recentProjects = recentProjects
        self._selection = selection
        self._focusedField = focusedField
        self.dismissWindow = dismissWindow
    }

    private var isFocused: Bool {
        focusedField == .recentProjects
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
        .focused($focusedField, equals: .recentProjects)
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
            if colorScheme == .dark {
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

    // MARK: - Actions

    private func removeRecentProjects() {
        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
    }

    private func updateRecentProjects() {
        recentProjects = RecentProjectsStore.recentProjectURLs()
        if !recentProjects.isEmpty {
            selection = Set(recentProjects.prefix(1))
        }
    }
}

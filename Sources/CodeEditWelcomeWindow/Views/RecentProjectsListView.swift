////
////  RecentProjectsListView.swift
////  CodeEdit
////
////  Created by Wouter Hennen on 02/02/2023.
////
//
//import SwiftUI
//import CoreSpotlight
//import AppKit
//
//public struct RecentProjectsListView: View {
//    @State private var selection: Set<URL>
//    @State private var recentProjects: [URL]
//
//    private let documentHandler: ProjectDocumentHandler
//    private let dismissWindow: () -> Void
//
//    public init(documentHandler: ProjectDocumentHandler, dismissWindow: @escaping () -> Void) {
//        self.documentHandler = documentHandler
//        self.dismissWindow = dismissWindow
//        let urls = RecentProjectsStore.recentProjectURLs()
//        self._recentProjects = State(initialValue: urls)
//        self._selection = State(initialValue: Set(urls.prefix(1)))
//    }
//
//    private var listEmptyView: some View {
//        VStack {
//            Spacer()
//            Text(NSLocalizedString("No Recent Projects", comment: ""))
//                .font(.body)
//                .foregroundColor(.secondary)
//            Spacer()
//        }
//    }
//
//    public var body: some View {
//        List(recentProjects, id: \.self, selection: $selection) { project in
//            RecentProjectListItem(projectPath: project)
//        }
//        .listStyle(.sidebar)
//        .contextMenu(forSelectionType: URL.self) { items in
//            if !items.isEmpty {
//                Button("Show in Finder") {
//                    NSWorkspace.shared.activateFileViewerSelecting(Array(items))
//                }
//
//                Button("Copy path\(items.count > 1 ? "s" : "")") {
//                    let pasteBoard = NSPasteboard.general
//                    pasteBoard.clearContents()
//                    pasteBoard.writeObjects(selection.map(\.relativePath) as [NSString])
//                }
//
//                Button("Remove from Recents") {
//                    removeRecentProjects()
//                }
//            }
//        } primaryAction: { items in
//            for url in items {
//                guard RecentProjectsStore.beginAccessing(url) else {
//                    print("❌ Could not access recent project (security scope failure): \(url.path)")
//                    continue
//                }
//
//                documentHandler.openDocument(at: url) {
//                    RecentProjectsStore.endAccessing(url)
//                    dismissWindow()
//                }
//            }
//        }
//        .onCopyCommand {
//            selection.map { NSItemProvider(object: $0.path(percentEncoded: false) as NSString) }
//        }
//        .onDeleteCommand {
//            removeRecentProjects()
//        }
////        .background(EffectView(.underWindowBackground, blendingMode: .behindWindow))
//        .background {
//            Button("") {
//                selection.forEach { url in
//                    documentHandler.openDocument(at: url) {
//                        dismissWindow()
//                    }
//                }
//            }
//            .keyboardShortcut(.defaultAction)
//            .hidden()
//        }
//        .overlay {
//            if recentProjects.isEmpty {
//                listEmptyView
//            }
//        }
//        .onReceive(NotificationCenter.default.publisher(for: RecentProjectsStore.didUpdateNotification)) { _ in
//            updateRecentProjects()
//        }
//    }
//
//    private func removeRecentProjects() {
//        recentProjects = RecentProjectsStore.removeRecentProjects(selection)
//    }
//
//    private func updateRecentProjects() {
//        recentProjects = RecentProjectsStore.recentProjectURLs()
//    }
//}

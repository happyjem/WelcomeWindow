//
//  WelcomeWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//
import SwiftUI

public struct WelcomeWindow: Scene {
    private let contentBuilder: (_ dismissWindow: @escaping () -> Void) -> AnyView
    private let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
    private let viewCount: Int

    // MARK: - 1 View
    public init<A: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> A,
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in AnyView(content(dismiss)) }
        self.onDrop = onDrop
        self.viewCount = 1
    }

    // MARK: - 2 Views
    public init<A: View, B: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B),
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1)))
        }
        self.onDrop = onDrop
        self.viewCount = 2
    }

    // MARK: - 3 Views
    public init<A: View, B: View, C: View>(
        content: @escaping (_ dismissWindow: @escaping () -> Void) -> (A, B, C),
        onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)? = nil
    ) {
        self.contentBuilder = { dismiss in
            let views = content(dismiss)
            return AnyView(TupleView((views.0, views.1, views.2)))
        }
        self.onDrop = onDrop
        self.viewCount = 3
    }

    public var body: some Scene {
        Window("Welcome To \(Bundle.displayName)", id: DefaultSceneID.welcome) {
            ContentView(
                content: contentBuilder,
                onDrop: onDrop,
                viewCount: viewCount
            )
            .frame(width: 740, height: 432)
            .task {
                if let window = NSApp.findWindow(DefaultSceneID.welcome) {
                    

                    window.standardWindowButton(.closeButton)?.isHidden = true
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    
                    window.isMovableByWindowBackground = true
                    
                  
                }
            }
            
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        

    }

    private struct ContentView: View {
        let content: (_ dismissWindow: @escaping () -> Void) -> AnyView
        let onDrop: ((_ url: URL, _ dismiss: @escaping () -> Void) -> Void)?
        let viewCount: Int

        var body: some View {
            WelcomeWindowView(
                content: content,
                onDrop: onDrop,
                viewCount: viewCount
            )
        }
    }
}

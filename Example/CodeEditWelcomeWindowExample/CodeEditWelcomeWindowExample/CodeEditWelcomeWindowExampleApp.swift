//
//  CodeEditWelcomeWindowExampleApp.swift
//  CodeEditWelcomeWindowExample
//
//  Created by Giorgi Tchelidze on 24.05.25.
//

import SwiftUI

@main
struct CodeEditWelcomeWindowExampleApp: App {
    
    private let handler = TXTDocumentController.shared
    
    var body: some Scene {
        Group {
            WelcomeWindow(documentHandler: handler )
        }
    }
}

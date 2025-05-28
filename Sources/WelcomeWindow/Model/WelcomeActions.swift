//
//  WelcomeActions.swift
//  WelcomeWindow
//
//  Created by Giorgi Tchelidze on 28.05.25.
//

import SwiftUI

public enum WelcomeActions {
    case none
    case one(AnyView)
    case two(AnyView, AnyView)
    case three(AnyView, AnyView, AnyView)

    public var count: Int {
        switch self {
        case .none: return 0
        case .one: return 1
        case .two: return 2
        case .three: return 3
        }
    }
}

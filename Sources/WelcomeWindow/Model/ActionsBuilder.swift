//
//  ActionsBuilder.swift
//  WelcomeWindow
//
//  Created by Giorgi Tchelidze on 28.05.25.
//
import SwiftUI

@resultBuilder
public enum ActionsBuilder {
    public static func buildBlock() -> WelcomeActions {
        .none
    }

    public static func buildBlock<V1: View>(_ v1: V1) -> WelcomeActions {
        .one(AnyView(v1))
    }

    public static func buildBlock<V1: View, V2: View>(_ v1: V1, _ v2: V2) -> WelcomeActions {
        .two(AnyView(v1), AnyView(v2))
    }

    public static func buildBlock<V1: View, V2: View, V3: View>(_ v1: V1, _ v2: V2, _ v3: V3) -> WelcomeActions {
        .three(AnyView(v1), AnyView(v2), AnyView(v3))
    }
}

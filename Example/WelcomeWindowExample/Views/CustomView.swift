//
//  CustomView.swift
//  WelcomeWindowExample
//
//  Created by Giorgi Tchelidze on 28.05.25.
//
import SwiftUI

enum UpToThreeViews {
    case none
    case one(AnyView)
    case two(AnyView, AnyView)
    case three(AnyView, AnyView, AnyView)
}

@resultBuilder
struct UpToThreeViewBuilder {
    static func buildBlock() -> UpToThreeViews {
        .none
    }

    static func buildBlock<V1: View>(_ v1: V1) -> UpToThreeViews {
        .one(AnyView(v1))
    }

    static func buildBlock<V1: View, V2: View>(_ v1: V1, _ v2: V2) -> UpToThreeViews {
        .two(AnyView(v1), AnyView(v2))
    }

    static func buildBlock<V1: View, V2: View, V3: View>(_ v1: V1, _ v2: V2, _ v3: V3) -> UpToThreeViews {
        .three(AnyView(v1), AnyView(v2), AnyView(v3))
    }
}


struct UpToThreeViewsContainer: View {
    let views: UpToThreeViews

    init(@UpToThreeViewBuilder content: () -> UpToThreeViews) {
        self.views = content()
    }

    var body: some View {
        VStack {
            switch views {
            case .none:
                EmptyView()
            case .one(let view1):
                view1
            case let .two(view1, view2):
                view1
                view2
            case let .three(view1, view2, view3):
                view1
                view2
                view3
            }
        }
    }
}

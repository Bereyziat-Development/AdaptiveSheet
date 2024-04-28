//
//  AdaptiveDismiss.swift
//
//
//  Created by Jonathan Bereyziat on 28/04/2024.
//

import Foundation

import SwiftUI

private struct AdaptiveDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var adaptiveDismiss: () -> Void {
        get { self[AdaptiveDismissKey.self] }
        set { self[AdaptiveDismissKey.self] = newValue }
    }
}

struct AdaptiveDismissModifier: ViewModifier {
    let dismissAction: () -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.adaptiveDismiss, dismissAction)
    }
}

extension View {
    func adaptiveDismissHandler(dismissAction: @escaping () -> Void) -> some View {
        self.modifier(AdaptiveDismissModifier(dismissAction: dismissAction))
    }
}


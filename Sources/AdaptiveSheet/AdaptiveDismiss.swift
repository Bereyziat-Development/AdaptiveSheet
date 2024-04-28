//
//  AdaptiveDismiss.swift
//
//
//  Created by Jonathan Bereyziat on 28/04/2024.
//

import Foundation

import SwiftUI

@available(iOS 15, *)
struct AdaptiveDismissKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

@available(iOS 15, *)
public extension EnvironmentValues {
    var adaptiveDismiss: () -> Void {
        get { self[AdaptiveDismissKey.self] }
        set { self[AdaptiveDismissKey.self] = newValue }
    }
}

@available(iOS 15, *)
struct AdaptiveDismissModifier: ViewModifier {
    let dismissAction: () -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.adaptiveDismiss, dismissAction)
    }
}

@available(iOS 15, *)
extension View {
    func adaptiveDismissHandler(dismissAction: @escaping () -> Void) -> some View {
        self.modifier(AdaptiveDismissModifier(dismissAction: dismissAction))
    }
}


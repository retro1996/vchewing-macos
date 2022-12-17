// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
/// A type that applies standard interaction behavior to all progress views
/// within a view hierarchy.
///
/// To configure the current progress view style for a view hierarchy, use the
/// ``View/progressViewStyle(_:)`` modifier.
public protocol BackportProgressViewStyle {
  /// A type alias for the properties of a progress view instance.
  typealias Configuration = Backport<Any>.ProgressViewStyleConfiguration

  /// A view representing the body of a progress view.
  associatedtype Body: View

  /// Creates a view representing the body of a progress view.
  ///
  /// - Parameter configuration: The properties of the progress view being
  ///   created.
  ///
  /// The view hierarchy calls this method for each progress view where this
  /// style is the current progress view style.
  ///
  /// - Parameter configuration: The properties of the progress view, such as
  ///  its preferred progress type.
  @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
extension Backport where Wrapped: View {
  public func progressViewStyle<S: BackportProgressViewStyle>(_ style: S) -> some View {
    content.environment(\.backportProgressViewStyle, .init(style))
  }
}

internal struct AnyProgressViewStyle: BackportProgressViewStyle {
  let _makeBody: (Backport<Any>.ProgressViewStyleConfiguration) -> AnyView

  init<S: BackportProgressViewStyle>(_ style: S) {
    _makeBody = { config in
      AnyView(style.makeBody(configuration: config))
    }
  }

  func makeBody(configuration: Configuration) -> some View {
    _makeBody(configuration)
  }
}

private struct BackportProgressViewStyleEnvironmentKey: EnvironmentKey {
  static var defaultValue: AnyProgressViewStyle?
}

extension EnvironmentValues {
  var backportProgressViewStyle: AnyProgressViewStyle? {
    get { self[BackportProgressViewStyleEnvironmentKey.self] }
    set { self[BackportProgressViewStyleEnvironmentKey.self] = newValue }
  }
}

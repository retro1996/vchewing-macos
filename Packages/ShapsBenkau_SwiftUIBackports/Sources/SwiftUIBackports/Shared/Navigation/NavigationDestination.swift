// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(watchOS, deprecated: 9)
@available(macOS, deprecated: 13)
extension Backport where Wrapped: View {
  /// Associates a destination view with a presented data type for use within
  /// a navigation stack.
  ///
  /// Add this view modifer to a view inside a ``NavigationStack`` to
  /// describe the view that the stack displays when presenting
  /// a particular kind of data. Use a ``NavigationLink`` to present
  /// the data. For example, you can present a `ColorDetail` view for
  /// each presentation of a ``Color`` instance:
  ///
  ///     NavigationStack {
  ///         List {
  ///             NavigationLink("Mint", value: Color.mint)
  ///             NavigationLink("Pink", value: Color.pink)
  ///             NavigationLink("Teal", value: Color.teal)
  ///         }
  ///         .navigationDestination(for: Color.self) { color in
  ///             ColorDetail(color: color)
  ///         }
  ///         .navigationTitle("Colors")
  ///     }
  ///
  /// You can add more than one navigation destination modifier to the stack
  /// if it needs to present more than one kind of data.
  ///
  /// - Parameters:
  ///   - data: The type of data that this destination matches.
  ///   - destination: A view builder that defines a view to display
  ///     when the stack's navigation state contains a value of
  ///     type `data`. The closure takes one argument, which is the value
  ///     of the data to present.
  public func navigationDestination<D: Hashable, C: View>(for _: D.Type, @ViewBuilder destination: @escaping (D) -> C)
    -> some View
  {
    content
      .environment(
        \.navigationDestinations,
        [
          .init(type: D.self): .init { destination($0 as! D) },
        ]
      )
  }
}

@available(macOS 10.15, *)
@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(watchOS, deprecated: 9)
@available(macOS, deprecated: 13)
extension Backport where Wrapped == Any {
  public struct NavigationLink<Label, Destination>: View where Label: View, Destination: View {
    @Environment(\.navigationDestinations) private var destinations

    @available(macOS 10.15, *)
    private let valueType: AnyMetaType
    private let value: Any?
    private let label: Label
    private let destination: () -> Destination

    @available(macOS 10.15, *)
    public init<P>(value: P?, @ViewBuilder label: () -> Label) where Destination == Never {
      self.value = value
      valueType = .init(type: P.self)
      destination = { fatalError() }
      self.label = label()
    }

    @available(macOS 10.15, *)
    public var body: some View {
      SwiftUI.NavigationLink {
        if let value = value {
          destinations[valueType.type]?.content(value)
        }
      } label: {
        label
      }
      .disabled(value == nil)
    }
  }
}

@available(macOS 10.15, *)
private struct NavigationDestinationsEnvironmentKey: EnvironmentKey {
  static var defaultValue: [AnyMetaType: DestinationView] = [:]
}

@available(macOS 10.15, *)
private extension EnvironmentValues {
  var navigationDestinations: [AnyMetaType: DestinationView] {
    get { self[NavigationDestinationsEnvironmentKey.self] }
    set {
      var current = self[NavigationDestinationsEnvironmentKey.self]
      newValue.forEach { current[$0] = $1 }
      self[NavigationDestinationsEnvironmentKey.self] = current
    }
  }
}

@available(macOS 10.15, *)
private struct AnyMetaType {
  let type: Any.Type
}

@available(macOS 10.15, *)
extension AnyMetaType: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.type == rhs.type
  }
}

@available(macOS 10.15, *)
extension AnyMetaType: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(type))
  }
}

@available(macOS 10.15, *)
private extension Dictionary {
  subscript(_ key: Any.Type) -> Value? where Key == AnyMetaType {
    get { self[.init(type: key)] }
    _modify { yield &self[.init(type: key)] }
  }
}

@available(macOS 10.15, *)
private struct DestinationView: View {
  let content: (Any) -> AnyView
  var body: Never { fatalError() }
  init<Content: View>(content: @escaping (Any) -> Content) {
    self.content = { AnyView(content($0)) }
  }
}

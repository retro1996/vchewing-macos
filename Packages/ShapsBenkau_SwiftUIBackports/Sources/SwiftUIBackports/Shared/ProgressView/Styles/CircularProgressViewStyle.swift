// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
extension Backport where Wrapped == Any {
  /// A progress view that visually indicates its progress using a circular gauge.
  ///
  /// You can also use ``ProgressViewStyle/circular`` to construct this style.
  public struct CircularProgressViewStyle: BackportProgressViewStyle {
    /// Creates a circular progress view style.
    public init() {}

    @available(macOS 10.15, *)
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
    public func makeBody(configuration: Configuration) -> some View {
      VStack {
        #if !os(watchOS)
          CircularRepresentable(configuration: configuration)
        #endif

        configuration.label?
          .foregroundColor(.secondary)
      }
    }
  }
}

@available(macOS 10.15, *)
public extension BackportProgressViewStyle where Self == Backport<Any>.CircularProgressViewStyle {
  static var circular: Self { .init() }
}

#if os(macOS)
  @available(macOS 10.15, *)
  private struct CircularRepresentable: NSViewRepresentable {
    let configuration: Backport<Any>.ProgressViewStyleConfiguration

    @available(macOS 10.15, *)
    func makeNSView(context _: Context) -> NSProgressIndicator {
      .init()
    }

    @available(macOS 10.15, *)
    func updateNSView(_ view: NSProgressIndicator, context _: Context) {
      if let value = configuration.fractionCompleted {
        view.doubleValue = value
        view.maxValue = configuration.max
      }

      view.isIndeterminate = configuration.fractionCompleted == nil
      view.style = .spinning
      view.isDisplayedWhenStopped = true
      view.startAnimation(nil)
    }
  }

#elseif !os(watchOS)
  @available(macOS 10.15, *)
  private struct CircularRepresentable: UIViewRepresentable {
    let configuration: Backport<Any>.ProgressViewStyleConfiguration

    @available(macOS 10.15, *)
    func makeUIView(context _: Context) -> UIActivityIndicatorView {
      .init(style: .medium)
    }

    @available(macOS 10.15, *)
    func updateUIView(_ view: UIActivityIndicatorView, context _: Context) {
      view.hidesWhenStopped = false
      view.startAnimating()
    }
  }
#endif

// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(iOS, deprecated: 16)
@available(tvOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
@available(macOS 10.15, *)
extension Backport where Wrapped: View {
  /// Removes dimming from detents higher (and including) the provided identifier
  ///
  /// This has two affects on dentents higher than the identifier provided:
  /// 1. Touches will passthrough to the views below the sheet.
  /// 2. Touches will no longer dismiss the sheet automatically when tapping outside of the sheet.
  ///
  /// ```
  ///     struct ContentView: View {
  ///         @State private var showSettings = false
  ///
  ///         var body: some View {
  ///             Button("View Settings") {
  ///                 showSettings = true
  ///             }
  ///             .sheet(isPresented: $showSettings) {
  ///                 SettingsView()
  ///                     .presentationDetents:([.medium, .large])
  ///                     .presentationUndimmed(from: .medium)
  ///             }
  ///         }
  ///     }
  /// ```
  ///
  /// - Parameter identifier: The identifier of the largest detent that is not dimmed.
  @ViewBuilder
  @available(
    iOS, deprecated: 13, message: "Please use backport.presentationDetents(_:selection:largestUndimmedDetent:)"
  )
  public func presentationUndimmed(from identifier: Backport<Any>.PresentationDetent.Identifier?) -> some View {
    #if os(iOS)
      if #available(iOS 15, *) {
        content.background(Backport<Any>.Representable(identifier: identifier))
      } else {
        content
      }
    #else
      content
    #endif
  }
}

#if os(iOS)
  @available(iOS 15, *)
  extension Backport where Wrapped == Any {
    fileprivate struct Representable: UIViewControllerRepresentable {
      let identifier: Backport<Any>.PresentationDetent.Identifier?

      func makeUIViewController(context _: Context) -> Backport.Representable.Controller {
        Controller(identifier: identifier)
      }

      func updateUIViewController(_ controller: Backport.Representable.Controller, context _: Context) {
        controller.update(identifier: identifier)
      }
    }
  }

  @available(iOS 15, *)
  extension Backport.Representable {
    fileprivate final class Controller: UIViewController {
      var identifier: Backport<Any>.PresentationDetent.Identifier?

      init(identifier: Backport<Any>.PresentationDetent.Identifier?) {
        self.identifier = identifier
        super.init(nibName: nil, bundle: nil)
      }

      @available(*, unavailable)
      required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        update(identifier: identifier)
      }

      func update(identifier: Backport<Any>.PresentationDetent.Identifier?) {
        self.identifier = identifier

        if let controller = parent?.sheetPresentationController {
          controller.animateChanges {
            controller.presentingViewController.view.tintAdjustmentMode = .normal
            controller.largestUndimmedDetentIdentifier = identifier.flatMap {
              .init(rawValue: $0.rawValue)
            }
          }
        }
      }
    }
  }
#endif

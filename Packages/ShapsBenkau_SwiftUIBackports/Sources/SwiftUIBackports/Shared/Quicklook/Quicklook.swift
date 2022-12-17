// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

#if canImport(QuickLook)
  import QuickLook
#endif

@available(iOS, deprecated: 14)
@available(macOS, deprecated: 11)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(macOS 10.15, *)
extension Backport where Wrapped: View {
  /// Presents a Quick Look preview of the URLs you provide.
  ///
  /// The Quick Look preview appears when you set the binding to a non-`nil` item.
  /// When you set the item back to `nil`, Quick Look dismisses the preview.
  /// If the value of the selection binding isn’t contained in the items collection, Quick Look treats it the same as a `nil` selection.
  ///
  /// Quick Look updates the value of the selection binding to match the URL of the file the user is previewing.
  /// Upon dismissal by the user, Quick Look automatically sets the item binding to `nil`.
  ///
  /// - Parameters:
  ///     - selection: A <doc://com.apple.documentation/documentation/SwiftUI/Binding> to an element that’s part of the items collection. This is the URL that you currently want to preview.
  ///     - items: A collection of URLs to preview.
  ///
  /// - Returns: A view that presents the preview of the contents of the URL.
  public func quickLookPreview<Items>(_ selection: Binding<Items.Element?>, in items: Items) -> some View
  where Items: RandomAccessCollection, Items.Element == URL {
    #if os(iOS) || os(macOS)
      content.background(QuicklookSheet(selection: selection, items: items))
    #else
      content
    #endif
  }

  /// Presents a Quick Look preview of the contents of a single URL.
  ///
  /// The Quick Look preview appears when you set the binding to a non-`nil` item.
  /// When you set the item back to `nil`, Quick Look dismisses the preview.
  ///
  /// Upon dismissal by the user, Quick Look automatically sets the item binding to `nil`.
  /// Quick Look displays the preview when a non-`nil` item is set.
  /// Set `item` to `nil` to dismiss the preview.
  ///
  /// - Parameters:
  ///     - item: A <doc://com.apple.documentation/documentation/SwiftUI/Binding> to a URL that should be previewed.
  ///
  /// - Returns: A view that presents the preview of the contents of the URL.
  public func quickLookPreview(_ item: Binding<URL?>) -> some View {
    #if os(iOS) || os(macOS)
      content.background(QuicklookSheet(selection: item, items: [item.wrappedValue].compactMap { $0 }))
    #else
      content
    #endif
  }
}

#if os(macOS)
  import QuickLookUI

  @available(macOS 10.15, *)
  private struct QuicklookSheet<Items>: NSViewControllerRepresentable
  where Items: RandomAccessCollection, Items.Element == URL {
    let selection: Binding<Items.Element?>
    let items: Items

    func makeNSViewController(context _: Context) -> PreviewController<Items> {
      .init(selection: selection, in: items)
    }

    func updateNSViewController(_ controller: PreviewController<Items>, context _: Context) {
      controller.selection = selection
      controller.items = items
    }
  }

#elseif os(iOS)

  private struct QuicklookSheet<Items>: UIViewControllerRepresentable
  where Items: RandomAccessCollection, Items.Element == URL {
    let selection: Binding<Items.Element?>
    let items: Items

    func makeUIViewController(context _: Context) -> PreviewController<Items> {
      .init(selection: selection, in: items)
    }

    func updateUIViewController(_ controller: PreviewController<Items>, context _: Context) {
      controller.items = items
      controller.selection = selection
    }
  }

#endif

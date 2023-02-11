// (c) 2018 and onwards Sindre Sorhus (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

/// Represents a type that can be converted to `PreferencePane`.
///
/// Acts as type-eraser for `Preferences.Pane<T>`.
public protocol PreferencePaneConvertible {
  /**
   Convert `self` to equivalent `PreferencePane`.
   */
  func asPreferencePane() -> PreferencePane
}

@available(macOS 10.15, *)
public extension SSPreferences {
  /**
   Create a SwiftUI-based preference pane.

   SwiftUI equivalent of the `PreferencePane` protocol.
   */
  struct Pane<Content: View>: View, PreferencePaneConvertible {
    let identifier: PaneIdentifier
    let title: String
    let toolbarIcon: NSImage
    let content: Content

    public init(
      identifier: PaneIdentifier,
      title: String,
      toolbarIcon: NSImage,
      contentView: () -> Content
    ) {
      self.identifier = identifier
      self.title = title
      self.toolbarIcon = toolbarIcon
      content = contentView()
    }

    public var body: some View { content }

    public func asPreferencePane() -> PreferencePane {
      PaneHostingController(pane: self)
    }
  }

  /**
   Hosting controller enabling `Preferences.Pane` to be used alongside AppKit `NSViewController`'s.
   */
  final class PaneHostingController<Content: View>: NSHostingController<Content>, PreferencePane {
    public let preferencePaneIdentifier: PaneIdentifier
    public let preferencePaneTitle: String
    public let toolbarItemIcon: NSImage

    init(
      identifier: PaneIdentifier,
      title: String,
      toolbarIcon: NSImage,
      content: Content
    ) {
      preferencePaneIdentifier = identifier
      preferencePaneTitle = title
      toolbarItemIcon = toolbarIcon
      super.init(rootView: content)
    }

    public convenience init(pane: Pane<Content>) {
      self.init(
        identifier: pane.identifier,
        title: pane.title,
        toolbarIcon: pane.toolbarIcon,
        content: pane.content
      )
    }

    @available(*, unavailable)
    @objc
    dynamic required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

@available(macOS 10.15, *)
public extension View {
  /**
   Applies font and color for a label used for describing a preference.
   */
  func preferenceDescription() -> some View {
    font(.system(size: 11.0))
      // TODO: Use `.foregroundStyle` when targeting macOS 12.
      .foregroundColor(.secondary)
  }
}

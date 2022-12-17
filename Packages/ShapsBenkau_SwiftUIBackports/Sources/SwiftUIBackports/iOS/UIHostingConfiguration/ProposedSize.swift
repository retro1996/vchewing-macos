// (c) 2022 and onwards Shaps Benkau (MIT License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

import SwiftUI

@available(macOS 10.15, *)
/// A proposal for the size
///
/// * The ``zero`` proposal; the size responds with its minimum size.
/// * The ``infinity`` proposal; the size responds with its maximum size.
/// * The ``unspecified`` proposal; the size responds with its system default size.
internal struct ProposedSize: Equatable, Sendable {
  /// The proposed horizontal size measured in points.
  ///
  /// A value of `nil` represents an unspecified width proposal.
  public var width: CGFloat?

  @available(macOS 10.15, *)
  /// The proposed vertical size measured in points.
  ///
  /// A value of `nil` represents an unspecified height proposal.
  public var height: CGFloat?

  @available(macOS 10.15, *)
  /// A size proposal that contains zero in both dimensions.
  public static var zero: ProposedSize { .init(width: 0, height: 0) }

  @available(macOS 10.15, *)
  /// The proposed size with both dimensions left unspecified.
  ///
  /// Both dimensions contain `nil` in this size proposal.
  public static var unspecified: ProposedSize { .init(width: nil, height: nil) }

  @available(macOS 10.15, *)
  /// A size proposal that contains infinity in both dimensions.
  ///
  /// Both dimensions contain .infinity in this size proposal.
  public static var infinity: ProposedSize { .init(width: .infinity, height: .infinity) }

  @available(macOS 10.15, *)
  /// Creates a new proposed size using the specified width and height.
  ///
  /// - Parameters:
  ///   - width: A proposed width in points. Use a value of `nil` to indicate
  ///     that the width is unspecified for this proposal.
  ///   - height: A proposed height in points. Use a value of `nil` to
  ///     indicate that the height is unspecified for this proposal.
  @inlinable public init(width: CGFloat?, height: CGFloat?) {
    self.width = width
    self.height = height
  }

  @available(macOS 10.15, *)
  /// Creates a new proposed size from a specified size.
  ///
  /// - Parameter size: A proposed size with dimensions measured in points.
  @inlinable public init(_ size: CGSize) {
    width = size.width
    height = size.height
  }
}

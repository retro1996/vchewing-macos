// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import PhraseEditorUI
import Shared
import SwiftExtension
import SwiftUI

@available(macOS 13, *)
public struct VwrSettingsPanePhrases: View {
  public var body: some View {
    ScrollView {
      VStack {
        GroupBox {
          VwrPhraseEditorUI(delegate: LMMgr.shared, window: CtlSettingsUI.shared?.window)
            .padding(4)
            .frame(maxWidth: .infinity)
            .frame(height: 440)
        }
      }
      .padding(4)
      .padding()
      .frame(minWidth: CtlSettingsUI.formWidth, maxWidth: ceil(CtlSettingsUI.formWidth * 1.2))
    }
    .frame(maxHeight: CtlSettingsUI.contentMaxHeight)
  }
}

@available(macOS 13, *)
struct VwrSettingsPanePhrases_Previews: PreviewProvider {
  static var previews: some View {
    VwrSettingsPanePhrases()
  }
}

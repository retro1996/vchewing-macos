// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import IMKUtils
import MainAssembly
import Shared
import SSPreferences
import SwiftExtension
import SwiftUI
import SwiftUIBackports

@available(macOS 10.15, *)
struct VwrPrefPaneKeyboard: View {
  // MARK: - AppStorage Variables

  @Backport.AppStorage(wrappedValue: 0, UserDef.kKeyboardParser.rawValue)
  private var keyboardParser: Int

  @Backport.AppStorage(
    wrappedValue: PrefMgr.kDefaultBasicKeyboardLayout,
    UserDef.kBasicKeyboardLayout.rawValue
  )
  private var basicKeyboardLayout: String

  @Backport.AppStorage(
    wrappedValue: PrefMgr.kDefaultAlphanumericalKeyboardLayout,
    UserDef.kAlphanumericalKeyboardLayout.rawValue
  )
  private var alphanumericalKeyboardLayout: String

  // MARK: - Main View

  var body: some View {
    ScrollView {
      Form {
        Section {
          HStack(alignment: .top) {
            Text("Quick Setup:")
            Spacer()
            Button {
              keyboardParser = 0
              basicKeyboardLayout = "com.apple.keylayout.ZhuyinBopomofo"
            } label: {
              Text("↻ㄅ" + " " + NSLocalizedString("Dachen Trad.", comment: ""))
            }
            Button {
              keyboardParser = 1
              basicKeyboardLayout = "com.apple.keylayout.ZhuyinEten"
            } label: {
              Text("↻ㄅ" + " " + NSLocalizedString("Eten Trad.", comment: ""))
            }
            Button {
              keyboardParser = 100
              basicKeyboardLayout = "com.apple.keylayout.ABC"
            } label: {
              Text("↻Ａ")
            }
          }
          VStack(alignment: .leading) {
            Picker(
              "Phonetic Parser:",
              selection: $keyboardParser
            ) {
              ForEach(KeyboardParser.allCases, id: \.self) { item in
                if [7, 100].contains(item.rawValue) { Divider() }
                Text(item.localizedMenuName).tag(item.rawValue)
              }.id(UUID())
            }
            Spacer()
            Text(NSLocalizedString("Choose the phonetic layout for Mandarin parser.", comment: ""))
              .settingsDescription()
          }

          VStack(alignment: .leading) {
            HStack {
              Picker(
                "Basic Keyboard Layout:",
                selection: $basicKeyboardLayout
              ) {
                ForEach(0 ... (IMKHelper.allowedBasicLayoutsAsTISInputSources.count - 1), id: \.self) { id in
                  let theEntry = IMKHelper.allowedBasicLayoutsAsTISInputSources[id]
                  if let theEntry = theEntry {
                    Text(theEntry.vChewingLocalizedName).tag(theEntry.identifier)
                  } else {
                    Divider()
                  }
                }.id(UUID())
              }
            }
            Spacer()
            Text(
              NSLocalizedString(
                "Choose the macOS-level basic keyboard layout. Non-QWERTY alphanumerical keyboard layouts are for Pinyin parser only. This option will only affect the appearance of the on-screen-keyboard if the current Mandarin parser is neither (any) pinyin nor dynamically reparsable with different western keyboard layouts (like Eten 26, Hsu, etc.).",
                comment: ""
              )
            )
            .settingsDescription()
          }
          VStack(alignment: .leading) {
            HStack {
              Picker(
                "Alphanumerical Layout:",
                selection: $alphanumericalKeyboardLayout
              ) {
                ForEach(0 ... (IMKHelper.allowedAlphanumericalTISInputSources.count - 1), id: \.self) { id in
                  let theEntry = IMKHelper.allowedAlphanumericalTISInputSources[id]
                  Text(theEntry.vChewingLocalizedName).tag(theEntry.identifier)
                }.id(UUID())
              }
            }
            Spacer()
            Text(
              NSLocalizedString(
                "Choose the macOS-level alphanumerical keyboard layout. This setting is for Shift-toggled alphanumerical mode only.",
                comment: ""
              )
            )
            .settingsDescription()
          }
        }
        Section(header: Text("Keyboard Shortcuts:")) {
          VwrPrefPaneKeyboard_KeyboardShortcuts()
        }
      }.formStyled().frame(width: CtlPrefUIShared.formWidth)
    }
    .frame(maxHeight: CtlPrefUIShared.contentMaxHeight)
  }
}

@available(macOS 10.15, *)
private struct VwrPrefPaneKeyboard_KeyboardShortcuts: View {
  // MARK: - AppStorage Variables

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeySCPC.rawValue)
  private var usingHotKeySCPC: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyAssociates.rawValue)
  private var usingHotKeyAssociates: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyCNS.rawValue)
  private var usingHotKeyCNS: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyKangXi.rawValue)
  private var usingHotKeyKangXi: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyJIS.rawValue)
  private var usingHotKeyJIS: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyHalfWidthASCII.rawValue)
  private var usingHotKeyHalfWidthASCII: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyCurrencyNumerals.rawValue)
  private var usingHotKeyCurrencyNumerals: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyCassette.rawValue)
  private var usingHotKeyCassette: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyRevLookup.rawValue)
  private var usingHotKeyRevLookup: Bool

  @Backport.AppStorage(wrappedValue: true, UserDef.kUsingHotKeyInputMode.rawValue)
  private var usingHotKeyInputMode: Bool

  // MARK: - Main View

  var body: some View {
    HStack(alignment: .top, spacing: NSFont.systemFontSize) {
      VStack(alignment: .leading) {
        Toggle(
          LocalizedStringKey("Per-Char Select Mode"),
          isOn: $usingHotKeySCPC
        )
        Toggle(
          LocalizedStringKey("Per-Char Associated Phrases"),
          isOn: $usingHotKeyAssociates
        )
        Toggle(
          LocalizedStringKey("CNS11643 Mode"),
          isOn: $usingHotKeyCNS
        )
        Toggle(
          LocalizedStringKey("Force KangXi Writing"),
          isOn: $usingHotKeyKangXi
        )
        Toggle(
          LocalizedStringKey("Reverse Lookup (Phonabets)"),
          isOn: $usingHotKeyRevLookup
        )
      }
      Divider()
      VStack(alignment: .leading) {
        Toggle(
          LocalizedStringKey("JIS Shinjitai Output"),
          isOn: $usingHotKeyJIS
        )
        Toggle(
          LocalizedStringKey("Half-Width Punctuation Mode"),
          isOn: $usingHotKeyHalfWidthASCII
        )
        Toggle(
          LocalizedStringKey("Currency Numeral Output"),
          isOn: $usingHotKeyCurrencyNumerals
        )
        Toggle(
          LocalizedStringKey("CIN Cassette Mode"),
          isOn: $usingHotKeyCassette
        )
        Toggle(
          LocalizedStringKey("CHS / CHT Input Mode Switch"),
          isOn: $usingHotKeyInputMode
        )
      }
    }
  }
}

@available(macOS 11.0, *)
struct VwrPrefPaneKeyboard_Previews: PreviewProvider {
  static var previews: some View {
    VwrPrefPaneKeyboard()
  }
}

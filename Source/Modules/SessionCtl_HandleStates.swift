// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import PopupCompositionBuffer
import Shared

// MARK: - 狀態調度 (State Handling)

extension SessionCtl {
  /// 針對傳入的新狀態進行調度。
  ///
  /// 先將舊狀態單獨記錄起來，再將新舊狀態作為參數，
  /// 根據新狀態本身的狀態種類來判斷交給哪一個專門的函式來處理。
  /// - Remark: ⚠️ 任何在這個函式當中被改變的變數均不得是靜態 (Static) 變數。
  /// 針對某一個客體的 deactivateServer() 可能會在使用者切換到另一個客體應用
  /// 且開始敲字之後才會執行。這個過程會使得不同的 SessionCtl 副本之間出現
  /// 不必要的互相干涉、打斷彼此的工作。
  /// - Parameter newState: 新狀態。
  public func handle(state newState: IMEStateProtocol, replaceCurrent: Bool = true) {
    var previous = state
    if replaceCurrent { state = newState }
    switch newState.type {
      case .ofDeactivated:
        ctlCandidateCurrent.visible = false
        popupCompositionBuffer.hide()
        tooltipInstance.hide()
        if previous.hasComposition {
          commit(text: previous.displayedText)
        }
        clearInlineDisplay()
        // 最後一道保險
        keyHandler.clear()
        // 特殊處理：deactivateServer() 可能會遲於另一個客體會話的 activateServer() 執行。
        // 雖然所有在這個函式內影響到的變數都改為動態變數了（不會出現跨副本波及的情況），
        // 但 IMKCandidates 是有內部共用副本的、會被波及。
        // 所以在這裡糾偏一下、讓所有開啟了選字窗的會話重新顯示選字窗。
        if PrefMgr.shared.useIMKCandidateWindow {
          for instance in Self.allInstances {
            guard let imkC = instance.ctlCandidateCurrent as? CtlCandidateIMK else { continue }
            if instance.state.isCandidateContainer, !imkC.visible {
              instance.handle(state: instance.state, replaceCurrent: false)
            }
          }
        }
      case .ofEmpty, .ofAbortion:
        if newState.type == .ofAbortion {
          previous = IMEState.ofEmpty()
          if replaceCurrent { state = previous }
        }
        ctlCandidateCurrent.visible = false
        tooltipInstance.hide()
        // 全專案用以判斷「.Abortion」的地方僅此一處。
        if previous.hasComposition, newState.type != .ofAbortion {
          commit(text: previous.displayedText)
        }
        // 在這裡手動再取消一次選字窗與工具提示的顯示，可謂雙重保險。
        tooltipInstance.hide()
        clearInlineDisplay()
        // 最後一道保險
        keyHandler.clear()
      case .ofCommitting:
        ctlCandidateCurrent.visible = false
        tooltipInstance.hide()
        commit(text: newState.textToCommit)
        clearInlineDisplay()
        // 最後一道保險
        keyHandler.clear()
      case .ofInputting:
        ctlCandidateCurrent.visible = false
        tooltipInstance.hide()
        commit(text: newState.textToCommit)
        setInlineDisplayWithCursor()
        showTooltip(newState.tooltip)
      case .ofMarking:
        ctlCandidateCurrent.visible = false
        setInlineDisplayWithCursor()
        showTooltip(newState.tooltip)
      case .ofCandidates, .ofAssociates, .ofSymbolTable:
        tooltipInstance.hide()
        setInlineDisplayWithCursor()
        showCandidates()
      default: break
    }
    // 浮動組字窗的顯示判定
    if newState.hasComposition, PrefMgr.shared.clientsIMKTextInputIncapable.contains(clientBundleIdentifier) {
      popupCompositionBuffer.isTypingDirectionVertical = isVerticalTyping
      popupCompositionBuffer.show(
        state: newState, at: lineHeightRect(zeroCursor: true).origin
      )
    } else {
      popupCompositionBuffer.hide()
    }
  }

  /// 針對受 .NotEmpty() 管轄的非空狀態，在組字區內顯示游標。
  public func setInlineDisplayWithCursor() {
    if state.type == .ofAssociates {
      doSetMarkedText(
        state.data.attributedStringPlaceholder, selectionRange: NSRange(location: 0, length: 0),
        replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
      )
      return
    }

    if state.hasComposition || state.isCandidateContainer {
      /// 所謂選區「selectionRange」，就是「可見游標位置」的位置，只不過長度
      /// 是 0 且取代範圍（replacementRange）為「NSNotFound」罷了。
      /// 也就是說，內文組字區該在哪裡出現，得由客體軟體來作主。
      doSetMarkedText(
        attributedStringSecured.0, selectionRange: attributedStringSecured.1,
        replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
      )
      return
    }

    // 其它情形。
    clearInlineDisplay()
  }

  /// 在處理不受 .NotEmpty() 管轄的狀態時可能要用到的函式，會清空螢幕上顯示的內文組字區。
  /// 當 setInlineDisplayWithCursor() 在錯誤的狀態下被呼叫時，也會觸發這個函式。
  private func clearInlineDisplay() {
    doSetMarkedText(
      "", selectionRange: NSRange(location: 0, length: 0),
      replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
    )
  }

  /// 遞交組字區內容。
  /// 注意：必須在 IMK 的 commitComposition 函式當中也間接或者直接執行這個處理。
  private func commit(text: String) {
    guard let client = client(), !text.isEmpty else { return }
    let buffer = ChineseConverter.kanjiConversionIfRequired(text)
    if buffer.isEmpty {
      return
    }
    if let myID = Bundle.main.bundleIdentifier, let clientID = client.bundleIdentifier(), myID == clientID {
      DispatchQueue.main.async {
        client.insertText(
          buffer, replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
        )
      }
    } else {
      client.insertText(
        buffer, replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
      )
    }
  }

  /// 把 setMarkedText 包裝一下，按需啟用 GCD。
  public func doSetMarkedText(_ string: Any!, selectionRange: NSRange, replacementRange: NSRange) {
    guard let client = client() else { return }
    if let myID = Bundle.main.bundleIdentifier, let clientID = client.bundleIdentifier(), myID == clientID {
      DispatchQueue.main.async {
        client.setMarkedText(string, selectionRange: selectionRange, replacementRange: replacementRange)
      }
    } else {
      client.setMarkedText(string, selectionRange: selectionRange, replacementRange: replacementRange)
    }
  }
}

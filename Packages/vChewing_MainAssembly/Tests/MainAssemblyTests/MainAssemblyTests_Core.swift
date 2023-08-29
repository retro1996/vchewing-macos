// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import CocoaExtension
import InputMethodKit
import LangModelAssembly
@testable import MainAssembly
import Shared
import XCTest

let testClient = FakeClient()

public extension SessionCtl {
  override func client() -> (IMKTextInput & NSObjectProtocol)! { testClient }
}

func vCTestLog(_ str: String) {
  print("[VCLOG] \(str)")
}

/// 威注音輸入法的控制模組單元測試。
/// - Remark: 歡迎來到威注音輸入法的控制模組單元測試。
///
/// 不似其他同類產品的單元測試，威注音輸入法的單元測試
/// 會盡量模擬使用者的日常打字擊鍵行為與使用方法。
/// 單元測試的內容可能算不上豐富，但會隨著今後來自各位
/// 使用者所提報的故障、而繼續逐漸擴大測試範圍。
///
/// 該單元測試使用獨立的語彙資料，因此會在選字時的候選字
/// 順序等方面與威注音輸入法實際使用時的體驗有差異。
class MainAssemblyTests: XCTestCase {
  let testUOM = vChewingLM.LMUserOverride(dataURL: .init(fileURLWithPath: "/dev/null"))
  var testLM = vChewingLM.LMInstantiator.construct { $0.loadTestData() }
  static let testServer = IMKServer(name: "org.atelierInmu.vChewing.MainAssembly.UnitTests_Connection", bundleIdentifier: "org.atelierInmu.vChewing.MainAssembly.UnitTests")

  static var _testHandler: InputHandler?
  var testHandler: InputHandler {
    let result = Self._testHandler ?? InputHandler(lm: testLM, uom: testUOM, pref: PrefMgr.shared)
    if Self._testHandler == nil { Self._testHandler = result }
    return result
  }

  static var _testSession: SessionCtl?
  var testSession: SessionCtl {
    guard let session = Self._testSession ?? SessionCtl(server: Self.testServer, delegate: testHandler, client: testClient) else {
      fatalError("Session failed from booting!")
    }
    if Self._testSession == nil { Self._testSession = session }
    return session
  }

  // MARK: - Utilities

  let dataArrowLeft = NSEvent.KeyEventData(chars: NSEvent.SpecialKey.leftArrow.unicodeScalar.description, keyCode: KeyCode.kLeftArrow.rawValue)
  let dataArrowDown = NSEvent.KeyEventData(chars: NSEvent.SpecialKey.downArrow.unicodeScalar.description, keyCode: KeyCode.kDownArrow.rawValue)
  let dataEnterReturn = NSEvent.KeyEventData(chars: NSEvent.SpecialKey.carriageReturn.unicodeScalar.description, keyCode: KeyCode.kLineFeed.rawValue)
  let dataTab = NSEvent.KeyEventData(chars: NSEvent.SpecialKey.tab.unicodeScalar.description, keyCode: KeyCode.kTab.rawValue)

  func clearTestUOM() {
    testUOM.clearData(withURL: URL(fileURLWithPath: "/dev/null"))
  }

  func typeSentenceOrCandidates(_ sequence: String) {
    if !([.ofEmpty, .ofInputting].contains(testSession.state.type) || testSession.state.isCandidateContainer) { return }
    let typingSequence: [NSEvent] = sequence.compactMap { charRAW in
      var finalArray = [NSEvent]()
      let char = charRAW.description
      let keyEventData = NSEvent.KeyEventData(chars: char)
      finalArray.append(contentsOf: keyEventData.asPairedEvents)
      return finalArray
    }.flatMap { $0 }
    typingSequence.forEach { theEvent in
      let dismissed = !testSession.handle(theEvent, client: testClient)
      if theEvent.type == .keyDown { XCTAssertFalse(dismissed) }
    }
  }

  // MARK: - Preparing Unit Tests.

  override func setUpWithError() throws {
    UserDefaults.unitTests = .init(suiteName: "org.atelierInmu.vChewing.MainAssembly.UnitTests")
    UserDef.resetAll()
    UserDefaults.pendingUnitTests = true
    testSession.activateServer(testClient)
    testSession.isActivated = true
    testSession.inputHandler = testHandler
    testHandler.delegate = testSession
    testSession.syncBaseLMPrefs()
    testClient.clear()
  }

  override func tearDownWithError() throws {
    testSession.switchState(IMEState.ofAbortion())
    UserDefaults.unitTests?.removeSuite(named: "org.atelierInmu.vChewing.MainAssembly.UnitTests")
    UserDef.resetAll()
    testClient.clear()
    testSession.deactivateServer(testClient)
  }
}

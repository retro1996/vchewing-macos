// (c) 2011 and onwards The OpenVanilla Project (MIT License).
// All possible vChewing-specific modifications are of:
// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import AppKit
import FolderMonitor
import Shared
import Uninstaller
import UpdateSputnik
import UserNotifications

@objc(AppDelegate)
public class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
  public static let shared = AppDelegate()

  private var folderMonitor = FolderMonitor(
    url: URL(fileURLWithPath: LMMgr.dataFolderPath(isDefaultFolder: false))
  )

  public static var updateInfoSourceURL: URL? {
    guard let urlText = Bundle.main.infoDictionary?["UpdateInfoEndpoint"] as? String else {
      NSLog("vChewingDebug: Fatal error: Info.plist wrecked. It needs to have correct 'UpdateInfoEndpoint' value.")
      return nil
    }
    return .init(string: urlText)
  }

  public func checkUpdate(forced: Bool, shouldBypass: @escaping () -> Bool) {
    guard let url = Self.updateInfoSourceURL else { return }
    UpdateSputnik.shared.checkForUpdate(forced: forced, url: url) { shouldBypass() }
  }
}

// MARK: - Private Functions

extension AppDelegate {
  private func reloadOnFolderChangeHappens(forced: Bool = true) {
    // 拖 100ms 再重載，畢竟有些有特殊需求的使用者可能會想使用巨型自訂語彙檔案。
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
      // forced 用於剛剛切換了辭典檔案目錄的場合。
      // 先執行 initUserLangModels() 可以在目標辭典檔案不存在的情況下先行生成空白範本檔案。
      if PrefMgr.shared.shouldAutoReloadUserDataFiles || forced { LMMgr.initUserLangModels() }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
        if #available(macOS 10.15, *) { FileObserveProject.shared.touch() }
        if PrefMgr.shared.phraseEditorAutoReloadExternalModifications {
          Broadcaster.shared.eventForReloadingPhraseEditor = .init()
        }
      }
    }
  }
}

// MARK: - Public Functions

public extension AppDelegate {
  func applicationWillFinishLaunching(_: Notification) {
    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { _, _ in })

    PrefMgr.shared.fixOddPreferences()

    // 一旦發現與使用者半衰模組的觀察行為有關的崩潰標記被開啟：
    // 如果有開啟 Debug 模式的話，就將既有的半衰記憶資料檔案更名＋打上當時的時間戳。
    // 如果沒有開啟 Debug 模式的話，則將半衰記憶資料直接清空。
    if PrefMgr.shared.failureFlagForUOMObservation {
      LMMgr.relocateWreckedUOMData()
      PrefMgr.shared.failureFlagForUOMObservation = false
      let msgPackage = UNMutableNotificationContent()
      msgPackage.title = NSLocalizedString("vChewing", comment: "")
      msgPackage.body = NSLocalizedString(
        "vChewing crashed while handling previously loaded UOM observation data. These data files are cleaned now to ensure the usability.",
        comment: ""
      )
      msgPackage.sound = .defaultCritical
      UNUserNotificationCenter.current().add(
        .init(identifier: "vChewing.notification.uomCrash", content: msgPackage, trigger: nil),
        withCompletionHandler: nil
      )
    }

    if !PrefMgr.shared.onlyLoadFactoryLangModelsIfNeeded { LMMgr.loadDataModelsOnAppDelegate() }
    LMMgr.loadCassetteData()
    LMMgr.initUserLangModels()
    folderMonitor.folderDidChange = { [weak self] in
      guard let self = self else { return }
      self.reloadOnFolderChangeHappens()
    }
    if LMMgr.userDataFolderExists { folderMonitor.startMonitoring() }
  }

  func updateDirectoryMonitorPath() {
    folderMonitor.stopMonitoring()
    folderMonitor = FolderMonitor(
      url: URL(fileURLWithPath: LMMgr.dataFolderPath(isDefaultFolder: false))
    )
    folderMonitor.folderDidChange = { [weak self] in
      guard let self = self else { return }
      self.reloadOnFolderChangeHappens()
    }
    if LMMgr.userDataFolderExists { // 沒有資料夾的話，FolderMonitor 會崩潰。
      folderMonitor.startMonitoring()
      reloadOnFolderChangeHappens(forced: true)
    }
  }

  func selfUninstall() {
    let content = String(
      format: NSLocalizedString(
        "This will remove vChewing Input Method from this user account, requiring your confirmation.",
        comment: ""
      ))
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("Uninstallation", comment: "")
    alert.informativeText = content
    alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
    if #available(macOS 11, *) {
      alert.buttons.forEach { button in
        button.hasDestructiveAction = true
      }
    }
    alert.addButton(withTitle: NSLocalizedString("Not Now", comment: ""))
    let result = alert.runModal()
    NSApp.popup()
    guard result == NSApplication.ModalResponse.alertFirstButtonReturn else { return }
    let url = URL(fileURLWithPath: LMMgr.dataFolderPath(isDefaultFolder: true))
    guard let finderURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.finder") else { return }
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.promptsUserIfNeeded = true
    NSWorkspace.shared.open([url], withApplicationAt: finderURL, configuration: configuration)
    Uninstaller.uninstall(
      isSudo: false, selfKill: true, defaultDataFolderPath: LMMgr.dataFolderPath(isDefaultFolder: true)
    )
  }

  /// 檢查該程式本身的記憶體佔用量。
  /// - Returns: 記憶體佔用量（MiB）。
  @discardableResult func checkMemoryUsage() -> Double {
    guard let currentMemorySizeInBytes = NSApplication.memoryFootprint else { return 0 }
    let currentMemorySize: Double = (Double(currentMemorySizeInBytes) / 1024 / 1024).rounded(toPlaces: 1)
    switch currentMemorySize {
    case 768...:
      vCLog("WARNING: EXCESSIVE MEMORY FOOTPRINT (\(currentMemorySize)MB).")
      let msgPackage = UNMutableNotificationContent()
      msgPackage.title = NSLocalizedString("vChewing", comment: "")
      msgPackage.body = NSLocalizedString(
        "vChewing is rebooted due to a memory-excessive-usage problem. If convenient, please inform the developer that you are having this issue, stating whether you are using an Intel Mac or Apple Silicon Mac. An NSLog is generated with the current memory footprint size.",
        comment: ""
      )
      UNUserNotificationCenter.current().add(
        .init(
          identifier: "vChewing.notification.memoryExcessiveUsage",
          content: msgPackage, trigger: nil
        ),
        withCompletionHandler: nil
      )
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        NSApp.terminate(self)
      }
    default: break
    }
    return currentMemorySize
  }
}

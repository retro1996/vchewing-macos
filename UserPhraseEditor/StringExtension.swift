// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import Foundation

extension String {
  mutating func regReplace(pattern: String, replaceWith: String = "") {
    // Ref: https://stackoverflow.com/a/40993403/4162914 && https://stackoverflow.com/a/71291137/4162914
    do {
      let regex = try NSRegularExpression(
        pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines]
      )
      let range = NSRange(startIndex..., in: self)
      self = regex.stringByReplacingMatches(
        in: self, options: [], range: range, withTemplate: replaceWith
      )
    } catch { return }
  }

  mutating func selfReplace(_ strOf: String, _ strWith: String = "") {
    self = replacingOccurrences(of: strOf, with: strWith)
  }

  mutating func formatConsolidate() {
    // Step 1: Consolidating formats per line.
    var strProcessed = self
    // 預處理格式
    strProcessed = strProcessed.replacingOccurrences(of: " #MACOS", with: "")  // 去掉 macOS 標記
    // CJKWhiteSpace (\x{3000}) to ASCII Space
    // NonBreakWhiteSpace (\x{A0}) to ASCII Space
    // Tab to ASCII Space
    // 統整連續空格為一個 ASCII 空格
    strProcessed.regReplace(pattern: #"( +|　+| +|\t+)+"#, replaceWith: " ")
    // 去除行尾行首空格
    strProcessed.regReplace(pattern: #"(^ | $)"#, replaceWith: "")
    strProcessed.regReplace(pattern: #"(\n | \n)"#, replaceWith: "\n")
    // CR & FF to LF, 且去除重複行
    strProcessed.regReplace(pattern: #"(\f+|\r+|\n+)+"#, replaceWith: "\n")
    if strProcessed.prefix(1) == " " {  // 去除檔案開頭空格
      strProcessed.removeFirst()
    }
    if strProcessed.suffix(1) == " " {  // 去除檔案結尾空格
      strProcessed.removeLast()
    }

    // Step 3: Add Formatted Pragma, the Sorted Header:
    let hdrFormatted = "# 𝙵𝙾𝚁𝙼𝙰𝚃 𝚘𝚛𝚐.𝚊𝚝𝚎𝚕𝚒𝚎𝚛𝙸𝚗𝚖𝚞.𝚟𝚌𝚑𝚎𝚠𝚒𝚗𝚐.𝚞𝚜𝚎𝚛𝙻𝚊𝚗𝚐𝚞𝚊𝚐𝚎𝙼𝚘𝚍𝚎𝚕𝙳𝚊𝚝𝚊.𝚏𝚘𝚛𝚖𝚊𝚝𝚝𝚎𝚍\n"
    strProcessed = hdrFormatted + strProcessed  // Add Sorted Header

    // Step 4: Deduplication.
    let arrData = strProcessed.split(separator: "\n")
    // 下面兩行的 reversed 是首尾顛倒，免得破壞最新的 override 資訊。
    let arrDataDeduplicated = Array(NSOrderedSet(array: arrData.reversed()).array as! [String])
    strProcessed = arrDataDeduplicated.reversed().joined(separator: "\n") + "\n"

    // Step 5: Remove duplicated newlines at the end of the file.
    strProcessed.regReplace(pattern: "\\n+", replaceWith: "\n")

    // Step 6: Commit Formatted Contents.
    self = strProcessed
  }
}

// (c) 2022 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import Cocoa
import Shared
import SwiftUI
import SwiftUIBackports

// MARK: - Some useless tests

@available(macOS 10.15, *)
struct CandidatePoolViewUIHorizontalBackports_Previews: PreviewProvider {
  @State static var testCandidates: [String] = [
    "八月中秋山林涼", "八月中秋", "風吹大地", "山林涼", "草枝擺", "八月", "中秋",
    "🐂🍺🐂🍺", "🐃🍺", "🐂🍺", "🐃🐂🍺🍺", "🐂🍺", "🐃🍺", "🐂🍺", "🐃🍺", "🐂🍺", "🐃🍺",
    "山林", "風吹", "大地", "草枝", "八", "月", "中", "秋", "山", "林", "涼", "風",
    "吹", "大", "地", "草", "枝", "擺", "八", "月", "中", "秋", "山", "林", "涼", "風",
    "吹", "大", "地", "草", "枝", "擺",
  ]
  static var thePool: CandidatePool {
    let result = CandidatePool(candidates: testCandidates, rowCapacity: 6)
    // 下一行待解決：無論這裡怎麼指定高亮選中項是哪一筆，其所在行都得被卷動到使用者眼前。
    result.highlight(at: 5)
    return result
  }

  static var previews: some View {
    VwrCandidateHorizontalBackports(controller: .init(.horizontal), thePool: thePool).fixedSize()
  }
}

@available(macOS 10.15, *)
public struct VwrCandidateHorizontalBackports: View {
  @Environment(\.colorScheme) var colorScheme
  public var controller: CtlCandidateTDK
  @State public var thePool: CandidatePool
  @State public var tooltip: String = ""

  private var positionLabel: String {
    (thePool.highlightedIndex + 1).description + "/" + thePool.candidateDataAll.count.description
  }

  private func didSelectCandidateAt(_ pos: Int) {
    if let delegate = controller.delegate {
      delegate.candidatePairSelected(at: pos)
    }
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ScrollView(.vertical, showsIndicators: false) {
        VStack(alignment: .leading, spacing: 1.6) {
          ForEach(thePool.rangeForCurrentPage, id: \.self) { rowIndex in
            HStack(spacing: 10) {
              ForEach(Array(thePool.candidateLines[rowIndex]), id: \.self) { currentCandidate in
                currentCandidate.attributedStringForSwiftUIBackports.fixedSize()
                  .frame(
                    maxWidth: .infinity,
                    alignment: .topLeading
                  )
                  .contentShape(Rectangle())
                  .onTapGesture { didSelectCandidateAt(currentCandidate.index) }
              }
            }.frame(
              minWidth: 0,
              maxWidth: .infinity,
              alignment: .topLeading
            ).id(rowIndex)
            Divider()
          }
          if thePool.maxLinesPerPage - thePool.rangeForCurrentPage.count > 0 {
            ForEach(thePool.rangeForLastPageBlanked, id: \.self) { _ in
              HStack(spacing: 0) {
                thePool.blankCell.attributedStringForSwiftUIBackports
                  .frame(maxWidth: .infinity, alignment: .topLeading)
                  .contentShape(Rectangle())
                Spacer()
              }.frame(
                minWidth: 0,
                maxWidth: .infinity,
                alignment: .topLeading
              )
              Divider()
            }
          }
        }
      }
      .fixedSize(horizontal: false, vertical: true).padding(5)
      .background(Color(white: colorScheme == .dark ? 0.1 : 1))
      ZStack(alignment: .leading) {
        if tooltip.isEmpty {
          Color(white: colorScheme == .dark ? 0.2 : 0.9)
        } else {
          controller.highlightedColorUIBackports
        }
        HStack(alignment: .bottom) {
          Text(tooltip).font(.system(size: max(CandidateCellData.unifiedSize * 0.7, 11), weight: .bold)).lineLimit(1)
          Spacer()
          Text(positionLabel).font(.system(size: max(CandidateCellData.unifiedSize * 0.7, 11), weight: .bold))
            .lineLimit(
              1)
        }
        .padding(6).foregroundColor(
          tooltip.isEmpty && colorScheme == .light ? Color(white: 0.1) : Color(white: 0.9)
        )
      }
    }
    .frame(minWidth: thePool.maxWindowWidth, maxWidth: thePool.maxWindowWidth)
  }
}

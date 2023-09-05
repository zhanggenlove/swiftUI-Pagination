//
//  Pagination.swift
//  swiftUI-Pagination
//
//  Created by 张根 on 2023/9/5.
//

import SwiftUI
import Combine
import Foundation

struct Pagination: View {
    @Binding var pageCount: Int
    @Binding var currentPage: Int
    @State private var selfPageCount: Int = 0
    @State private var selfCurrentPage: Int = 0
    var pagerCount: Int = 7
    // 防止endless loop flag
    @State var isPageCountFirstReceive: Bool = true
    // State
    @State private var showPrevMore = false
    @State private var prevMoreHover = false
    @State private var showNextMore = false
    @State private var nextMoreHover = false
    @StateObject private var pagersMVVM: PagersMVVM = .init()

    // HOVER
    @State private var leftBtnHover: Bool = false
    @State private var rightBtnHover: Bool = false
    @State private var firstBtnHover: Bool = false
    @State private var lastBtnHover: Bool = false
    // 色值
    let activeColor: Color = .blue
    let activeTextColor: Color = .white
    let defaultColor: Color = .init(hex: "#303133")
    let disableColor: Color = .init(hex: "#c0c4cc")
    let defaultBgColor: Color = .init(hex: "#f4f4f5")
    let activeBgColor: Color = .blue
    private func computedPagers() {
        NSCursor.pointingHand.pop()
        let halfPagerCount = (pagerCount - 1) / 2
        var showPrevMore = false
        var showNextMore = false
        if pageCount > pagerCount {
            if currentPage > pagerCount - halfPagerCount {
                showPrevMore = true
            }

            if currentPage < pageCount - halfPagerCount {
                showNextMore = true
            }
        }
        var array: [Int] = []
        if showPrevMore && !showNextMore {
            let startPage = pageCount - (pagerCount - 2)
            let arr = Array(startPage ..< pageCount)
            array.append(contentsOf: arr)
        } else if !showPrevMore && showNextMore {
            let arr = Array(2 ..< pagerCount)
            array.append(contentsOf: arr)
        } else if showPrevMore && showNextMore {
            let offset = Int(floor(Double(pagerCount) / 2) - 1)
            let arr = Array(currentPage - offset ... currentPage + offset)
            array.append(contentsOf: arr)
        } else {
            let arr = Array(2 ..< pageCount)
            array.append(contentsOf: arr)
        }
        self.showPrevMore = showPrevMore
        self.showNextMore = showNextMore
        pagersMVVM.setPagers(array: array)
        print("pagers: ", pagersMVVM.list)
    }

    var body: some View {
        HStack(spacing: 5) {
            // 左边箭头按钮
            Button {
                // 只有一页和当前页是1的时候不做任何
                guard pageCount != 0, currentPage != 1 else { return }
                currentPage = currentPage - 1
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 30, height: 28)
                    .contentShape(Rectangle())
                    .foregroundColor((pageCount == 0 || currentPage == 1) ? disableColor : leftBtnHover ? activeColor : defaultColor)
            }
            .disabled(pageCount == 0 || currentPage == 1)
            .buttonStyle(.plain)
            .frame(minWidth: 30, maxHeight: 28)
            .background(RoundedRectangle(cornerRadius: 4)
                .fill(defaultBgColor)
            )
            .onHover { status in
                leftBtnHover = status
                if pageCount == 0 || currentPage == 1 {
                    if status {
                        NSCursor.operationNotAllowed.push()
                    } else {
                        NSCursor.operationNotAllowed.pop()
                    }
                } else {
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
            // 第一页
            Button {
                guard currentPage != 1 else { return }
                currentPage = 1
            } label: {
                Text("1")
                    .frame(minWidth: 30, maxHeight: 28)
                    .foregroundColor(currentPage == 1 ? activeTextColor : firstBtnHover ? activeColor : defaultColor)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(minWidth: 30, maxHeight: 28)
            .background(RoundedRectangle(cornerRadius: 4)
                .fill(currentPage == 1 ? activeBgColor : defaultBgColor)
            )
            .onHover { status in
                firstBtnHover = status
                if currentPage != 1 {
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
            // 前置省略
            if showPrevMore {
                Button {
                    let pagerCountOffset = pagerCount - 2
                    let newPage = currentPage - pagerCountOffset
                    if newPage != currentPage {
                        currentPage = newPage
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 28)
                        .contentShape(Rectangle())
                        .foregroundColor(defaultColor)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 30, maxHeight: 28)
                .background(RoundedRectangle(cornerRadius: 4)
                    .fill(defaultBgColor)
                )
                .onHover { status in
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
            // 中间部分
            ForEach(pagersMVVM.list, id: \.index) { pager in
                Button {
                    let newPage = pager.index
                    currentPage = newPage
                } label: {
                    Text("\(pager.index)")
                        .frame(minWidth: 30, maxHeight: 28)
                        .contentShape(Rectangle())
                        .foregroundColor(currentPage == pager.index ? activeTextColor : pager.hover ? activeColor : defaultColor)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 30, maxHeight: 28)
                .background(RoundedRectangle(cornerRadius: 4)
                    .fill(currentPage == pager.index ? activeBgColor : defaultBgColor)
                )
                .onHover { status in
                    pager.hover = status
                    if currentPage != pager.index {
                        if status {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pointingHand.pop()
                        }
                    }
                }
            }
            // 后置省略
            if showNextMore {
                Button {
                    let pagerCountOffset = pagerCount - 2
                    let newPage = currentPage + pagerCountOffset
                    if newPage != currentPage {
                        currentPage = newPage
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 30, height: 28)
                        .contentShape(Rectangle())
                        .foregroundColor(defaultColor)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 30, maxHeight: 28)
                .background(RoundedRectangle(cornerRadius: 4)
                    .fill(defaultBgColor)
                )
                .onHover { status in
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
            // 最后一页
            Button {
                guard currentPage != pageCount else { return }
                currentPage = pageCount
            } label: {
                Text("\(pageCount)")
                    .frame(minWidth: 30, maxHeight: 28)
                    .contentShape(Rectangle())
                    .foregroundColor(currentPage == pageCount ? activeTextColor : lastBtnHover ? activeColor : defaultColor)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 30, maxHeight: 28)
            .background(RoundedRectangle(cornerRadius: 4)
                .fill(currentPage == pageCount ? activeBgColor : defaultBgColor)
            )
            .onHover { status in
                lastBtnHover = status
                if currentPage != pageCount {
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
            // 右侧的箭头按钮
            Button {
                // 只有一页和当前页是pagecount的时候不做任何
                guard pageCount != 0, currentPage != pageCount else { return }
                currentPage = currentPage + 1
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 30, height: 28)
                    .contentShape(Rectangle())
                    .foregroundColor((pageCount == 0 || currentPage == pageCount) ? disableColor : leftBtnHover ? activeColor : defaultColor)
            }
            .disabled(pageCount == 0 || currentPage == pageCount)
            .buttonStyle(.plain)
            .frame(minWidth: 30, maxHeight: 28)
            .background(RoundedRectangle(cornerRadius: 4).fill(defaultBgColor))
            .onHover { status in
                leftBtnHover = status
                if pageCount == 0 || currentPage == pageCount {
                    if status {
                        NSCursor.operationNotAllowed.push()
                    } else {
                        NSCursor.operationNotAllowed.pop()
                    }
                } else {
                    if status {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pointingHand.pop()
                    }
                }
            }
        }
        .onHover(perform: { status in
            if !status {
                NSCursor.pointingHand.pop()
            }
        })
//        .background(Color.white.opacity(0.6))
        .onReceive(Just(currentPage)) { _ in
            if currentPage != selfCurrentPage {
                selfCurrentPage = currentPage
                computedPagers()
            }
        }
        .onReceive(Just(pageCount)) { _ in
            if isPageCountFirstReceive {
                isPageCountFirstReceive = false
                computedPagers()
            }
        }
    }
}

struct Pagination_Previews: PreviewProvider {
    static var previews: some View {
        @State var pageCount = 100
        @State var currentPage = 1
        Pagination(pageCount: $pageCount, currentPage: $currentPage)
    }
}

class PagersMVVM: ObservableObject {
    @Published var list: [PagerItem] = []
    
    func setPagers(array: [Int]) {
        list.removeAll()
        let finalArr = array.map { index in
            PagerItem(index: index)
        }
        list.append(contentsOf: finalArr)
    }
}

class PagerItem: ObservableObject {
    var index: Int
    @Published var hover: Bool = false

    init(index: Int) {
        self.index = index
    }
}

extension View {
    func whenHovered(_ mouseIsInside: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(mouseIsInside))
    }
}

struct MouseInsideModifier: ViewModifier {
    let mouseIsInside: (Bool) -> Void
    
    init(_ mouseIsInside: @escaping (Bool) -> Void) {
        self.mouseIsInside = mouseIsInside
    }
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Representable(mouseIsInside: mouseIsInside,
                              frame: proxy.frame(in: .global))
            }
        )
    }
    
    private struct Representable: NSViewRepresentable {
        let mouseIsInside: (Bool) -> Void
        let frame: NSRect
        
        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.mouseIsInside = mouseIsInside
            return coordinator
        }
        
        class Coordinator: NSResponder {
            var mouseIsInside: ((Bool) -> Void)?
            
            override func mouseEntered(with event: NSEvent) {
                mouseIsInside?(true)
            }
            
            override func mouseExited(with event: NSEvent) {
                mouseIsInside?(false)
            }
        }
        
        func makeNSView(context: Context) -> NSView {
            let view = NSView(frame: frame)
            
            let options: NSTrackingArea.Options = [
                .mouseEnteredAndExited,
                .inVisibleRect,
                .activeInKeyWindow
            ]
            
            let trackingArea = NSTrackingArea(rect: frame,
                                              options: options,
                                              owner: context.coordinator,
                                              userInfo: nil)
            
            view.addTrackingArea(trackingArea)
            
            return view
        }
        
        func updateNSView(_ nsView: NSView, context: Context) {}
        
        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
        }
    }
}


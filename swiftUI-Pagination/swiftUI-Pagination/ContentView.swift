//
//  ContentView.swift
//  swiftUI-Pagination
//
//  Created by 张根 on 2023/9/5.
//

import SwiftUI

struct ContentView: View {
    @State var pageCount: Int = 100 // 总的页数
    @State var currentPage: Int = 12  // 当前页
    var body: some View {
        VStack {
            Pagination(pageCount: $pageCount, currentPage: $currentPage)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

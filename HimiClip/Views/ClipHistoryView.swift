//
//  ClipHistoryView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ClipHistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var page = 1
    @State private var searchText: String = ""
    private let requestManager = RequestManager()

    var filteredClipHistory: [ClipEntry] {
        if searchText.isEmpty {
            return appState.clipHistory
        } else {
            return appState.clipHistory.filter { $0.content.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {  // 使用 ZStack 使 ToastView 始终显示在 List 上方
                // 使用类似设置应用的背景颜色
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // 列表视图层
                    List {
                        ForEach(filteredClipHistory.indices, id: \.self) { index in
                            NavigationLink(destination: ClipDetailView(clip: $appState.clipHistory[index])) {  // 绑定到 appState.clipHistory[index]
                                Text(filteredClipHistory[index].content)
                                    .lineLimit(1)
                                    .onAppear {
                                        if index == filteredClipHistory.count - 1 && appState.hasMoreData && !appState.isFetching {
                                            loadMore()
                                        }
                                    }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    appState.deleteClip(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    CopyPasteButtons.copyToClipboard(content: filteredClipHistory[index].content)
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                .tint(.blue)
                            }
                        }

                        if appState.hasMoreData && appState.isFetching {
                            HStack {
                                ProgressView(NSLocalizedString("LOADING_MORE_CLIPS", comment: ""))
                            }
                        }
                    }
                    .navigationBarTitle(NSLocalizedString("HISTORY", comment: ""))
                    .searchable(text: $searchText, prompt: NSLocalizedString("SEARCH_CLIP", comment: ""))
                    .refreshable {
                        refreshData()  // 下拉刷新时调用
                    }
                }
            }
            .onAppear {
                if appState.clipHistory.isEmpty {
                    appState.fetchHistory(page: 1)
                }
            }
            // 将 ToastView 固定在页面底部
            .overlay(
                ToastView()
                    .padding(.bottom, 50) // 调整这个值来改变位置
                , alignment: .bottom
            )
        }
    }

    func loadMore() {
        page += 1
        appState.fetchHistory(page: page)
    }

    func refreshData() {
        page = 1
        appState.hasMoreData = true
        appState.clipHistory.removeAll()  // 清空现有数据
        appState.fetchHistory(page: 1)    // 重新加载第一页数据
    }
}

struct ClipDetailView: View {
    @EnvironmentObject var appState: AppState
    @Binding var clip: ClipEntry
    @State private var editContent: String = ""
    @State private var timeDescription: String = ""
    @StateObject private var toastManager = ToastManager()

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 文本编辑器
                TextEditor(text: $editContent)
                    .font(.body.weight(.black))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
                    .background(.indigo)
                    .cornerRadius(12)
                    .padding()

                // 时间描述
                Text(timeDescription)
                    .font(.footnote)
                    .foregroundColor(.gray)

                // 保存和复制粘贴按钮
                HStack {
                    SaveButton(clipId: clip.id, content: $editContent, originalContent: clip.content) {
                        clip.content = editContent
                        let updatedAt = DateUtility.currentDateInUTC8String()
                        clip = ClipEntry(id: clip.id, 
                                        userId: clip.userId, 
                                        content: editContent, 
                                        contentType: clip.contentType, 
                                        createdAt: clip.createdAt, 
                                        updatedAt: updatedAt, 
                                        username: clip.username)
                        updateTimeDescription()
                        appState.updateClipEntry(clip)
                    }
                    
                    CopyPasteButtons(content: $clip.content)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.editContent = clip.content
            updateTimeDescription()
        }
        .overlay(
            ToastView()
                .padding(.bottom, 50)
            , alignment: .bottom
        )
    }
    
    private func updateTimeDescription() {
        timeDescription = DateUtility.getRelativeTimeDescription(createdAt: clip.createdAt, updatedAt: clip.updatedAt)
    }
}

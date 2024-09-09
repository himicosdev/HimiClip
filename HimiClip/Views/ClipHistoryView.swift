//
//  ClipHistoryView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ClipHistoryView: View {
    @Binding var clipHistory: [ClipEntry]
    @State private var page = 1
    @State private var hasMoreData = true
    @State private var isFetching = false
    @State private var searchText: String = ""  // 添加搜索文本
    private let requestManager = RequestManager()  // 使用封装的 RequestManager

    var filteredClipHistory: [ClipEntry] {
        if searchText.isEmpty {
            return clipHistory
        } else {
            return clipHistory.filter { $0.content.lowercased().contains(searchText.lowercased()) }
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
                            NavigationLink(destination: ClipDetailView(clip: $clipHistory[index])) {  // 绑定到 clipHistory[index]
                                Text(filteredClipHistory[index].content)
                                    .lineLimit(1)
                                    .onAppear {
                                        if index == filteredClipHistory.count - 1 && hasMoreData && !isFetching {
                                            loadMore()
                                        }
                                    }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteClip(at: index)
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

                        if hasMoreData && isFetching {
                            HStack {
                                ProgressView("Loading more clips...")
                            }
                        }
                    }
                    .navigationBarTitle("History")
                    .searchable(text: $searchText, prompt: "Search Clip")
                    .refreshable {
                        refreshData()  // 下拉刷新时调用
                    }
                }
                // Toast View - 始终显示在屏幕底部
                VStack {
                    ToastView()
                }
            }
            .onAppear {
                if clipHistory.isEmpty {
                    fetchHistory(page: 1)  // 如果 clipHistory 为空，则重新获取数据
                }
            }
            // Toast View - 始终显示在屏幕底部
            VStack {
                ToastView()
            }
        }
    }

    func loadMore() {
        page += 1
        fetchHistory(page: page)
    }

    func refreshData() {
        page = 1
        hasMoreData = true
        clipHistory.removeAll()  // 清空现有数据
        fetchHistory(page: 1)    // 重新加载第一页数据
    }

    func fetchHistory(page: Int) {
        guard !isFetching else { return }

        let urlString = "http://localhost:8080/api/clips?page=\(page)&size=20"
        guard let url = URL(string: urlString) else { return }

        isFetching = true

        // 使用封装的 RequestManager 发起请求
        requestManager.performRequest(
            url: url,
            method: "GET",
            failureMessage: "Failed to load history",
            onSuccess: { data in  // 成功时处理返回的数据
                defer { isFetching = false }
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601  // 配置 JSONDecoder 以解析 ISO 8601 日期格式
                do {
                    let newClips = try decoder.decode([ClipEntry].self, from: data)
                    DispatchQueue.main.async {
                        if newClips.isEmpty {
                            self.hasMoreData = false
                        } else {
                            self.clipHistory.append(contentsOf: newClips)
                        }
                    }
                } catch {
                    print("Failed to decode response: \(error)")
                    DispatchQueue.main.async {
                        globalToastManager.showToast(message: "Failed to decode response", type: .failure)
                    }
                }
            },
            onFailure: {
                DispatchQueue.main.async {
                    self.isFetching = false
                }
            }
        )
    }

    func deleteClip(at index: Int) {
        let clip = clipHistory[index]
        guard let clipId = clip.id else { return }

        // 在删除成功之前，不立即从列表中删除，等请求成功后再移除
        guard let url = URL(string: "http://localhost:8080/api/clips/\(clipId)") else { return }

        // 使用封装的 RequestManager 发起请求
        requestManager.performRequest(
            url: url,
            method: "DELETE",
            successMessage: "Clip deleted successfully!",
            failureMessage: "Failed to delete clip.",
            onSuccess: { _ in
                // 成功后从历史记录中删除
                DispatchQueue.main.async {
                    clipHistory.remove(at: index)
                }
            }
        )
    }
}

struct ClipDetailView: View {
    @Binding var clip: ClipEntry  // 直接绑定到 ClipEntry
    @State var editContent: String = ""  // 复制一份在ClipDetailView视图中编辑
    @StateObject private var toastManager = ToastManager()

    var body: some View {
        ZStack {
            // 使用类似设置应用的背景颜色
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {

                // 文本输入区域
                TextEditor(text: $editContent)
                    .font(.body.weight(.black))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
                    .background(.indigo)
                    .cornerRadius(12)
                    .padding()

                if let dateLabel = DateUtility.getDisplayDateLabel(createdAt: clip.createdAt, updatedAt: clip.updatedAt) {
                    Text(dateLabel)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                // 保存、复制和粘贴按钮
                HStack {
                    SaveButton(clipId: clip.id, content: $editContent,originalContent: clip.content){
                        clip.content = editContent
                    }
                    
                    CopyPasteButtons(content: $clip.content)
                }
                Spacer()  // 将内容推到顶部，保持 ToastView 在底部
            }
            .padding()
            .navigationTitle("Edit Clip")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 在视图加载时初始化 editContent
                self.editContent = clip.content
            }

            // 将 ToastView 固定在页面底部
            VStack {
                ToastView()
            }
        }
    }
}

struct ClipHistory_Previews: PreviewProvider {
    static var previews: some View {
        ClipHistoryView(clipHistory: .constant([ClipEntry.defaultClip()]))
    }
}

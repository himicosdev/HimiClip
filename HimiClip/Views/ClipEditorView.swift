//
//  ClipEditorView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ClipEditorView: View {
    @Binding var clipHistory: [ClipEntry]
    @State private var lastClip: [ClipEntry] = [ClipEntry.defaultClip()]  // 使用默认剪切板内容
    @State var originalContent: String = ""  // 保存原始内容
    private let requestManager = RequestManager()  // 使用封装的 RequestManager

    var body: some View {
        ZStack {
            // 使用类似设置应用的背景颜色
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("HimiClip")
                    .font(.title)
                    .padding(.bottom, 20)

                // 文本输入区域
                if let clip = lastClip.first {
                    TextEditor(text: $lastClip[0].content)  // 直接绑定到 lastClip[0].content
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
                }

                // 保存、复制和粘贴按钮
                HStack {
                    SaveButton(content: $lastClip[0].content, originalContent: originalContent, onSuccess: {
                        // 成功保存后将最新的剪切板数据加入 clipHistory 中
                        fetchLatestClipFromBackend { latestClip in
                            // 成功获取最新数据后，插入到 clipHistory 的前面
                            if let latestClip = lastClip.first {
                                clipHistory.insert(latestClip, at: 0)
                            }
                        }
                    })

                    // 使用封装的 CopyPasteButtons 组件
                    CopyPasteButtons(content: $lastClip[0].content)
                }

                Spacer()  // 使用 Spacer 推动内容到顶部
            }
            .padding()
            .onAppear {
                if lastClip[0].id == nil {
                    fetchLatestClipFromBackend()  // 如果 lastClip 为空，加载最后一个剪切板内容
                }
            }

            // 将 ToastView 固定在页面底部
            VStack {
                ToastView()
            }
        }
    }
    
    // 从后端获取最后一个剪切板内容
    func fetchLatestClipFromBackend(completion: @escaping (ClipEntry?) -> Void = { _ in }) {
        let url = URL(string: "http://localhost:8080/api/clips?page=1&size=1")!
        
        requestManager.performRequest(
            url: url,
            method: "GET",
            failureMessage: "Failed to fetch latest clip."
        )
        { data in
            // 尝试解码 data 为 [ClipEntry] 数组对象
            if let decodedClips = try? JSONDecoder().decode([ClipEntry].self, from: data),
                let latestClip = decodedClips.first {
                // 保存解码后的数据
                self.lastClip = [latestClip]
                self.originalContent = latestClip.content  // 初始化 originalContent
                completion(latestClip)  // 调用回调，将最新的剪切板数据传回
            } else {
                // 当解码失败时，显示 toast 提示解码错误
                globalToastManager.showToast(message: "Failed to decode clip data", type: .failure)
                completion(nil)  // 调用回调，表示获取失败
            }
        }
    }
}

struct ClipEditor_Previews: PreviewProvider {
    static var previews: some View {
        ClipEditorView(clipHistory: .constant([ClipEntry.defaultClip()]))
    }
}

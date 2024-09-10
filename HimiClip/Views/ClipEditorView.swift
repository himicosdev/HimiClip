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
                Text(NSLocalizedString("HIMICLIP", comment: ""))
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
            .overlay(
                ToastView()
                    .padding(.bottom, 50) // 调整这个值来改变位置
                , alignment: .bottom
            )
        }
    }
    
    func fetchLatestClipFromBackend(completion: @escaping (ClipEntry?) -> Void = { _ in }) {
        let endpoint = "\(APIConstants.Endpoints.clips)?page=1&size=1"
        
        requestManager.performRequest(endpoint: endpoint, method: .get) { result in
            switch result {
            case .success(let data):
                if let decodedClips = try? JSONDecoder().decode([ClipEntry].self, from: data),
                    let latestClip = decodedClips.first {
                    DispatchQueue.main.async {
                        self.lastClip = [latestClip]
                        self.originalContent = latestClip.content
                        completion(latestClip)
                    }
                } else {
                    DispatchQueue.main.async {
                        globalToastManager.showToast(message: NSLocalizedString("DECODING_CLIPBOARD_DATA_FAILED", comment: ""), type: .failure)
                        completion(nil)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let errorMessage = String(format: NSLocalizedString("FETCHING_LATEST_CLIPBOARD_FAILED", comment: ""), error.localizedDescription)
                    globalToastManager.showToast(message: errorMessage, type: .failure)
                    completion(nil)
                }
            }
        }
    }
}

struct ClipEditor_Previews: PreviewProvider {
    static var previews: some View {
        ClipEditorView(clipHistory: .constant([ClipEntry.defaultClip()]))
    }
}

//
//  ClipboardActions.swift
//  HimiClip
//
//  Created by himicoswilson on 9/7/24.
//

import SwiftUI

struct SaveButton: View {
    var clipId: Int?  // 可选的 id，用于判断是否为更新操作
    @Binding var content: String  // 绑定内容
    var originalContent: String  // 初始内容，用于判断变化
    var onSuccess: (() -> Void)?
    private let requestManager = RequestManager()  // 使用封装的 RequestManager

    var body: some View {
        Button(action: {
            let clipEntry = ClipEntry(
                id: clipId,
                content: content,
                contentType: nil,
                createdAt: "",
                updatedAt: ""
            )
            saveContent(clipEntry: clipEntry)
        }) {
            Text(NSLocalizedString("SAVE", comment: ""))
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    func saveContent(clipEntry: ClipEntry) {
        guard !clipEntry.content.isEmpty else {
            globalToastManager.showToast(message: NSLocalizedString("NO_CONTENT_TO_SAVE", comment: ""), type: .warning)
            return
        }
        
        // 如果内容没有变化，直接返回，不发出请求
        if clipEntry.content == originalContent {
            globalToastManager.showToast(message: NSLocalizedString("CONTENT_UNCHANGED", comment: ""), type: .warning)
            return
        }

        var body: [String: Any] = [
            "content": clipEntry.content,
            "contentType": clipEntry.contentType ?? ""
        ]
        
        // 如果 `id` 不为 `nil`，则添加 `id` 字段
        if let id = clipEntry.id {
            body["id"] = id
        }
        
        // 使用封装的 RequestManager 发起请求
        requestManager.performRequest(endpoint: APIConstants.Endpoints.clips, method: .post, body: body) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    globalToastManager.showToast(message: NSLocalizedString("CLIP_SAVED", comment: ""), type: .success)
                    self.onSuccess?()
                case .failure(let error):
                    globalToastManager.showToast(message: NSLocalizedString("ERROR_SAVING_CLIP", comment: "") + ": \(error.localizedDescription)", type: .failure)
                }
            }
        }
    }
}

// 自定义的复制粘贴按钮组
struct CopyPasteButtons: View {
    @Binding var content: String  // 使用 @Binding 让父视图传递数据

    var body: some View {
        HStack {
            Button(action: {
                CopyPasteButtons.copyToClipboard(content: content)
            }) {
                Text(NSLocalizedString("COPY", comment: ""))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                content = CopyPasteButtons.pasteFromClipboard()
            }) {
                Text(NSLocalizedString("PASTE", comment: ""))
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }

    // 复制到剪切板的函数
    static func copyToClipboard(content: String) {
        UIPasteboard.general.string = content
        globalToastManager.showToast(message: NSLocalizedString("COPIED_TO_CLIPBOARD", comment: ""), type: .success)  // 复制成功后显示通知
    }

    // 从剪切板粘贴内容的函数
    static func pasteFromClipboard() -> String {
        let content = UIPasteboard.general.string ?? ""
        globalToastManager.showToast(message: NSLocalizedString("PASTED_FROM_CLIPBOARD", comment: ""), type: .success)  // 粘贴成功后显示通知
        return content
    }
}

//
//  ClipEditorView.swift
//  HimiClip
//
//  Created by himicoswilson on 9/5/24.
//

import SwiftUI

struct ClipEditorView: View {
    @EnvironmentObject var appState: AppState
    private let requestManager = RequestManager()

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(NSLocalizedString("HIMICLIP", comment: ""))
                    .font(.title)
                    .padding(.bottom, 20)

                // 文本输入区域
                TextEditor(text: $appState.lastClip.content)
                    .font(.body.weight(.black))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
                    .background(.indigo)
                    .cornerRadius(12)
                    .padding()

                Text(DateUtility.getRelativeTimeDescription(createdAt: appState.lastClip.createdAt, updatedAt: appState.lastClip.updatedAt))
                    .font(.footnote)
                    .foregroundColor(.gray)

                // 保存、复制和粘贴按钮
                HStack {
                    SaveButton(content: $appState.lastClip.content, originalContent: appState.originalContent,
                        onSuccess: {
                            appState.fetchLatestClipFromBackend { latestClip in
                                if let latestClip = latestClip {
                                    appState.clipHistory.insert(latestClip, at: 0)
                                }
                            }
                        }
                    )

                    // 使用封装的 CopyPasteButtons 组件
                    CopyPasteButtons(content: $appState.lastClip.content)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            if appState.lastClip.id == nil {
                appState.fetchLatestClipFromBackend()
            }
        }
        .overlay(
            ToastView()
                .padding(.bottom, 50)
            , alignment: .bottom
        )
    }
}
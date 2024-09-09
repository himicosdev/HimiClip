//
//  ToastManager.swift
//  HimiClip
//
//  Created by himicoswilson on 9/7/24.
//

import SwiftUI
import Combine

// Toast 类型枚举
enum ToastType {
    case success
    case failure
    case warning
}

class ToastManager: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var message: String = ""
    @Published var type: ToastType = .success  // 默认类型为成功
    
    private var activeTimer: AnyCancellable?

    // 显示带类型的 Toast，并设置消失时间
    func showToast(message: String, type: ToastType = .success, duration: TimeInterval = 3.0) {
        print("showToast")
        self.message = message
        self.type = type
        self.isVisible = true

        // 如果有正在运行的计时器，取消它
        activeTimer?.cancel()

        // 设置新的计时器，在指定的时间后隐藏 Toast
        activeTimer = Timer.publish(every: duration, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.hideToast()
            }
    }

    // 隐藏 Toast
    private func hideToast() {
        self.isVisible = false
        activeTimer?.cancel()
        activeTimer = nil
    }
}

struct ToastView: View {
    @ObservedObject var toastManager = globalToastManager
    
    var body: some View {
        ZStack {
            if globalToastManager.isVisible {
                Text(globalToastManager.message)
                    .padding()
                    .background(backgroundColor(for: globalToastManager.type))  // 根据类型设置背景颜色
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)  // 确保横向居中
                    .transition(.opacity)  // 添加淡入淡出动画
                    .padding(.top, 500)
            }
        }
    }

    // 根据 Toast 类型返回不同的背景颜色
    private func backgroundColor(for type: ToastType) -> Color {
        switch type {
        case .success:
            return Color.green
        case .failure:
            return Color.red
        case .warning:
            return Color.orange
        }
    }
}

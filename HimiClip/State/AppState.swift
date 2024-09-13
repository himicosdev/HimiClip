import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var clipHistory: [ClipEntry] = []
    @Published var lastClip: ClipEntry = ClipEntry.defaultClip()
    @Published var originalContent: String = ""
    @Published var hasMoreData: Bool = true
    @Published var isFetching: Bool = false
    
    private let requestManager = RequestManager()
    
    // 更新剪贴板最新的并同步到lastClip
    func updateClipEntry(_ updatedClip: ClipEntry) {
        if let index = clipHistory.firstIndex(where: { $0.id == updatedClip.id }) {
            clipHistory[index] = updatedClip
            if index == 0 {
                lastClip = updatedClip
                originalContent = updatedClip.content
            }
        } else if clipHistory.isEmpty {
            clipHistory.append(updatedClip)
            lastClip = updatedClip
            originalContent = updatedClip.content
        }
    }

    func fetchHistory(page: Int) {
        guard !isFetching else { return }
        isFetching = true

        let endpoint = "\(APIConstants.Endpoints.clips)?page=\(page)&size=20"
        
        requestManager.performRequest(endpoint: endpoint, method: .get) { result in
            DispatchQueue.main.async {
                self.isFetching = false
                switch result {
                case .success(let data):
                    do {
                        let newClips = try JSONDecoder().decode([ClipEntry].self, from: data)
                        if newClips.isEmpty {
                            self.hasMoreData = false
                        } else {
                            self.clipHistory.append(contentsOf: newClips)
                        }
                    } catch {
                        print("解码响应失败: \(error)")
                        globalToastManager.showToast(message: NSLocalizedString("DECODING_RESPONSE_FAILED", comment: ""), type: .failure)
                    }
                case .failure(let error):
                    print("加载历史记录失败: \(error.localizedDescription)")
                    let errorMessage = String(format: NSLocalizedString("LOADING_HISTORY_FAILED", comment: ""), error.localizedDescription)
                    globalToastManager.showToast(message: errorMessage, type: .failure)
                }
            }
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
                        self.lastClip = latestClip
                        self.originalContent = latestClip.content
                        completion(latestClip)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("解码剪贴板数据失败")
                        globalToastManager.showToast(message: NSLocalizedString("DECODING_CLIPBOARD_DATA_FAILED", comment: ""), type: .failure)
                        completion(nil)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("获取最新剪贴板失败: \(error.localizedDescription)")
                    let errorMessage = String(format: NSLocalizedString("FETCHING_LATEST_CLIPBOARD_FAILED", comment: ""), error.localizedDescription)
                    globalToastManager.showToast(message: errorMessage, type: .failure)
                    completion(nil)
                }
            }
        }
    }
    
    func deleteClip(at index: Int) {
        let clip = clipHistory[index]
        guard let clipId = clip.id else { return }

        let endpoint = "/\(clipId)"
        print(endpoint)

        requestManager.performRequest(endpoint: endpoint, method: .delete) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.clipHistory.remove(at: index)
                    globalToastManager.showToast(message: "剪贴板内容已成功删除！", type: .success)
                case .failure(let error):
                    globalToastManager.showToast(message: "删除剪贴板内容失败: \(error.localizedDescription)", type: .failure)
                }
            }
        }
    }
}

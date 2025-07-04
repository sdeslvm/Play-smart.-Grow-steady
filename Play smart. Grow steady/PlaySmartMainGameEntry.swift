import SwiftUI
import Foundation

struct PlaySmartEntryScreen: View {
    @StateObject private var loader: PlaySmartWebLoader

    init(loader: PlaySmartWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            PlaySmartWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                PlaySmartProgressIndicator(value: percent)
            case .failure(let err):
                PlaySmartErrorIndicator(err: err)
            case .noConnection:
                PlaySmartOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct PlaySmartProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            PlaySmartLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct PlaySmartErrorIndicator: View {
    let err: String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct PlaySmartOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}

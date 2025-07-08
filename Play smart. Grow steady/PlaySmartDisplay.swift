import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol PlaySmartProgressDisplayable {
    var progressPercentage: Int { get }
}





protocol PlaySmartBackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}






// MARK: - Расширенная структура загрузки

struct PlaySmartLoadingOverlay<Background: View>: View, PlaySmartProgressDisplayable {
    let progress: Double
    let backgroundView: Background
    
    var progressPercentage: Int { Int(progress * 100) }
    
    init(progress: Double, @ViewBuilder background: () -> Background) {
        self.progress = progress
        self.backgroundView = background()
    }
    
    
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Градиентный фон
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#1BD8FD"),
                        Color(hex: "#0FC9FA"),
                        Color(hex: "#0A1B2B")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Title и прогрессбар по центру
                VStack(spacing: 32) {
                    Spacer()
                    Image("title")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.7)
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeOut(duration: 0.5), value: progress)

                    VStack(spacing: 18) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)

                        PlaySmartProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.6, height: 12)
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 32)
                    .background(
                        BlurView(style: .systemUltraThinMaterialDark)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .opacity(0.85)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeOut(duration: 0.5), value: progress)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

extension PlaySmartLoadingOverlay where Background == PlaySmartBackground {
    init(progress: Double) {
        self.init(progress: progress) { PlaySmartBackground() }
    }
}

struct PlaySmartBackground: View, PlaySmartBackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct PlaySmartProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            progressContainer(in: geometry)
        }
    }
    
    private func progressContainer(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            backgroundTrack(height: geometry.size.height)
            progressTrack(in: geometry)
        }
    }
    
    private func backgroundTrack(height: CGFloat) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.15))
            .frame(height: height)
    }
    
    private func progressTrack(in geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color(hex: "#F3D614"))
            .frame(width: CGFloat(value) * geometry.size.width, height: geometry.size.height)
            .animation(.linear(duration: 0.2), value: value)
    }
}

// MARK: - BlurView для красивого фона блока прогресса

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Превью

#Preview("Vertical") {
    PlaySmartLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    PlaySmartLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}


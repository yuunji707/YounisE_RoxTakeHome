//
//  Extensions.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI



extension Color {
    static let appPrimary = Color("AppPrimary")
    static let appSecondary = Color("AppSecondary")
    static let appAccent = Color("AppAccent")
    static let appBackground = Color("AppBackground")
    static let appCardBackground = Color("AppCardBackground")
    static let appTextPrimary = Color("AppTextPrimary")
    static let appTextSecondary = Color("AppTextSecondary")
    
    static let gradientStart = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let gradientEnd = Color(red: 0.05, green: 0.05, blue: 0.15)
    
    static let neonCyan = Color(red: 0.0, green: 0.9, blue: 0.9)
    static let neonPurple = Color(red: 0.6, green: 0.3, blue: 0.9)
    static let neonPink = Color(red: 0.95, green: 0.3, blue: 0.6)
    
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    static let subtleText = Color(uiColor: .secondaryLabel)
}



extension View {
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    func glassBackground() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    func shimmer(when loading: Bool) -> some View {
        modifier(ShimmerModifier(isLoading: loading))
    }
}



struct ShimmerModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        if isLoading {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                    }
                    .mask(content)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}



struct CachedAsyncImage: View {
    let url: URL?
    let contentMode: ContentMode
    
    @State private var phase: AsyncImagePhase = .empty
    
    init(url: URL?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            switch phase {
            case .empty:
                placeholder
                    .overlay(ProgressView().tint(.gray))
                    .task { await loadImage() }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                placeholder
            @unknown default:
                placeholder
            }
        }
    }
    
    private var placeholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.neonPurple.opacity(0.3), Color.neonCyan.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "newspaper")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.5))
            )
    }
    
    private func loadImage() async {
        guard let url else {
            phase = .failure(URLError(.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        if let cached = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cached.data) {
            phase = .success(Image(uiImage: uiImage))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            
            if let uiImage = UIImage(data: data) {
                phase = .success(Image(uiImage: uiImage))
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}



enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

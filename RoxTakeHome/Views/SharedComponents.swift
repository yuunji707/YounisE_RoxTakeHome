//
//  SharedComponents.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.neonCyan.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [Color.neonCyan, Color.neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            VStack(spacing: 8) {
                Text("Loading Articles")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Fetching the latest news...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}


struct ErrorView: View {
    let error: NewsError
    let retryAction: () -> Void
    
    @State private var isRetrying = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: error.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.red.opacity(0.8))
            }
            
            VStack(spacing: 12) {
                Text("Something Went Wrong")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(error.errorDescription ?? "An error occurred")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(error.recoverySuggestion)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            Button {
                HapticManager.impact(.medium)
                isRetrying = true
                retryAction()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isRetrying = false
                }
            } label: {
                HStack(spacing: 8) {
                    if isRetrying {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Try Again")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color.neonCyan, Color.neonPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color.neonCyan.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .disabled(isRetrying)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}


struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.neonCyan.opacity(0.2), Color.neonPurple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.neonCyan, Color.neonPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            
            if let actionTitle, let action {
                Button {
                    HapticManager.impact(.medium)
                    action()
                } label: {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.neonCyan, Color.neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct SkeletonArticleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SkeletonRectangle(width: 80, height: 12)
                    Spacer()
                    SkeletonRectangle(width: 60, height: 12)
                }
                
                SkeletonRectangle(height: 16)
                SkeletonRectangle(width: 200, height: 16)
                
                SkeletonRectangle(height: 12)
                SkeletonRectangle(width: 150, height: 12)
            }
            .padding(16)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shimmer(when: true)
    }
}


struct SkeletonRectangle: View {
    var width: CGFloat? = nil
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.2))
            .frame(maxWidth: width ?? .infinity, minHeight: height, maxHeight: height)
    }
}


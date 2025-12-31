//
//  NewsDetailView.swift
//  RoxTakeHome
//
//  Created by Younis Ereiqat on 12/29/25.
//

import SwiftUI


struct NewsDetailView: View {
    @ObservedObject var viewModel: NewsDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                heroImageSection
                contentSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    shareButton
                    favoriteButton
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = viewModel.articleURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private var shareButton: some View {
        Button {
            HapticManager.impact(.light)
            showShareSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.body)
        }
    }
    
    private var favoriteButton: some View {
        Button {
            HapticManager.impact(.medium)
            viewModel.toggleFavorite()
        } label: {
            Image(systemName: viewModel.isFavorite ? "bookmark.fill" : "bookmark")
                .font(.body)
                .foregroundStyle(viewModel.isFavorite ? Color.neonCyan : .primary)
        }
    }
    
    private var heroImageSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                CachedAsyncImage(url: viewModel.article.urlToImage.flatMap { URL(string: $0) })
                    .frame(width: geometry.size.width, height: 280)
                    .clipped()
                
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                sourceBadge
                    .padding(16)
            }
        }
        .frame(height: 280)
    }
    
    private var sourceBadge: some View {
        Text(viewModel.article.source.name)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.neonCyan)
            .clipShape(Capsule())
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.article.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            metadataSection
            
            Divider()
            
            articleBodySection
            
            readFullArticleButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let author = viewModel.article.author, !author.isEmpty {
                Label(author, systemImage: "person.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Label(viewModel.article.formattedDate, systemImage: "clock")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var articleBodySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let description = viewModel.article.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let content = viewModel.article.content, !content.isEmpty {
                let cleanedContent = cleanArticleContent(content)
                
                Text(cleanedContent)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                
                if content.contains("[+") {
                    truncationNotice
                }
            }
        }
    }
    
    private var truncationNotice: some View {
        Label(
            "Content is truncated. Tap below to read the full article.",
            systemImage: "info.circle"
        )
        .font(.caption)
        .foregroundStyle(.tertiary)
        .padding(.top, 8)
    }
    
    private var readFullArticleButton: some View {
        VStack(spacing: 12) {
            if let url = viewModel.articleURL {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Text("Read Full Article")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.up.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [Color.neonCyan, Color.neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                Text("Opens in \(viewModel.article.source.name)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 8)
    }
    
    private func cleanArticleContent(_ content: String) -> String {
        var cleaned = content
        
        if let range = cleaned.range(of: "\\s*\\[\\+\\d+ chars\\]", options: .regularExpression) {
            cleaned = String(cleaned[..<range.lowerBound])
        }
        
        let replacements: [(String, String)] = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&apos;", "'"),
            ("&nbsp;", " "),
            ("<li>", "\n• "),
            ("</li>", ""),
            ("<ul>", ""),
            ("</ul>", ""),
            ("<ol>", ""),
            ("</ol>", ""),
            ("<p>", "\n"),
            ("</p>", ""),
            ("<br>", "\n"),
            ("<br/>", "\n"),
            ("<br />", "\n")
        ]
        
        for (old, new) in replacements {
            cleaned = cleaned.replacingOccurrences(of: old, with: new)
        }
        
        cleaned = cleaned.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        
        cleaned = cleaned.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

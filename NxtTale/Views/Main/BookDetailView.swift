import SwiftUI
import PDFKit

// ── PDF Reader Sheet ──
struct PDFReaderView: View {
    let bookTitle: String
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var totalPages  = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let url = Bundle.main.url(forResource: "book", withExtension: "pdf") {
                    PDFViewWrapper(url: url, currentPage: $currentPage, totalPages: $totalPages)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("PDF not found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Make sure 'book.pdf' is added to your project")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(bookTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
                if totalPages > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Text("\(currentPage + 1) / \(totalPages)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
}

// ── PDF View Wrapper with page tracking ──
struct PDFViewWrapper: UIViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages:  Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales         = true
        pdfView.displayMode        = .singlePageContinuous
        pdfView.displayDirection   = .vertical
        pdfView.backgroundColor    = .black
        pdfView.pageShadowsEnabled = true

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            DispatchQueue.main.async {
                self.totalPages = document.pageCount
            }
        }
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}

    class Coordinator: NSObject {
        var parent: PDFViewWrapper
        init(_ parent: PDFViewWrapper) { self.parent = parent }

        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let page    = pdfView.currentPage,
                  let doc     = pdfView.document else { return }
            DispatchQueue.main.async {
                self.parent.currentPage = doc.index(for: page)
            }
        }
    }
}

// ── Meta Info Widget ──
struct MetaItem: View {
    let icon:  String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }
            Text(value).font(.subheadline.bold())
            Text(label).font(.caption).foregroundColor(.secondary)
        }
    }
}

// ── Main Book Detail View ──
struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var appearedAt   = Date()
    @State private var showPDF      = false
    @State private var showFullDesc = false
    @State private var isBookmarked = false
    @State private var hasTracked   = false          // ← prevents duplicate tracking

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Hero Cover ──
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: book.coverImage ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure(_):
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(.white.opacity(0.6))
                            )
                        default:
                            Color.gray.opacity(0.2).overlay(ProgressView())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .clipped()

                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .frame(height: 160)
                }

                // ── Content ──
                VStack(alignment: .leading, spacing: 24) {

                    // ── Title + Author + Bookmark ──
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title)
                                .font(.title2.bold())
                                .fixedSize(horizontal: false, vertical: true)

                            if !book.authors.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(book.authorsText)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Spacer()
                        Button {
                            withAnimation(.spring()) { isBookmarked.toggle() }
                        } label: {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.title2)
                                .foregroundColor(isBookmarked ? .blue : .secondary)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }

                    // ── Read Book Button ──
                    Button { showPDF = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "book.pages.fill").font(.headline)
                            Text("Read Book").font(.headline.bold())
                            Spacer()
                            Image(systemName: "chevron.right").font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    // ── Meta Info ──
                    HStack(spacing: 0) {
                        if let rating = book.averageRating, rating > 0 {
                            MetaItem(icon: "star.fill", color: .yellow,
                                     label: "Rating", value: String(format: "%.1f", rating))
                                .frame(maxWidth: .infinity)
                        }
                        if let pages = book.pageCount, pages > 0 {
                            Divider().frame(height: 40)
                            MetaItem(icon: "doc.text.fill", color: .blue,
                                     label: "Pages", value: "\(pages)")
                                .frame(maxWidth: .infinity)
                        }
                        if let date = book.publishedDate, !date.isEmpty {
                            Divider().frame(height: 40)
                            MetaItem(icon: "calendar", color: .green,
                                     label: "Year", value: String(date.prefix(4)))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)

                    // ── Categories ──
                    if let categories = book.categories, !categories.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genres").font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(categories, id: \.self) { cat in
                                        Text(cat)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }

                    // ── Description ──
                    if let desc = book.description, !desc.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About this book").font(.headline)
                            Text(desc)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(showFullDesc ? nil : 4)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                withAnimation { showFullDesc.toggle() }
                            } label: {
                                Text(showFullDesc ? "Show less" : "Read more")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }

                    // ── Share + Save Row ──
                    HStack(spacing: 12) {
                        ShareLink(item: "Check out '\(book.title)' by \(book.authorsText) on NxtTale!") {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }

                        Button {
                            withAnimation(.spring()) { isBookmarked.toggle() }
                        } label: {
                            HStack {
                                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                Text(isBookmarked ? "Saved" : "Save")
                            }
                            .font(.subheadline.bold())
                            .foregroundColor(isBookmarked ? .white : .orange)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isBookmarked ? Color.orange : Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, -20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(false)

        // ── Track on OPEN — only once ──
        .onAppear {
            appearedAt = Date()
            guard !hasTracked else { return }   // ← blocks duplicate calls
            hasTracked = true
            Task {
                await RecommendService.shared.trackActivity(
                    token:        authVM.token,
                    bookId:       book.id,
                    googleBookId: book.googleBookId,
                    timeSpent:    10,
                    categories:   book.categories ?? [],
                    authors:      book.authors
                )
            }
        }

        // ── Track time spent on CLOSE ──
        .onDisappear {
            let seconds = Int(Date().timeIntervalSince(appearedAt))
            guard seconds > 2 else { return }
            Task {
                await RecommendService.shared.trackActivity(
                    token:        authVM.token,
                    bookId:       book.id,
                    googleBookId: book.googleBookId,
                    timeSpent:    seconds,
                    categories:   book.categories ?? [],
                    authors:      book.authors
                )
            }
        }

        .sheet(isPresented: $showPDF) {
            PDFReaderView(bookTitle: book.title)
        }
    }
}

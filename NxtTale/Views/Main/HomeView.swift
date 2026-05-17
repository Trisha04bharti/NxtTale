import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading && vm.feedBooks.isEmpty && vm.categories.isEmpty {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 30) {

                            // ── AI Recommendations ──
                            if !vm.recommendations.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.yellow)
                                        Text("Picked For You")
                                            .font(.title3.bold())
                                        Spacer()
                                    }
                                    .padding(.horizontal)

                                    if let reason = vm.recommendReason {
                                        Text(reason)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                    }

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 14) {
                                            ForEach(vm.recommendations) { book in
                                                BookCardView(book: book)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // ── Category Sections ──
                            ForEach(vm.categories) { section in
                                CategorySectionView(section: section)
                            }

                            // ── All Books List ──
                            if !vm.feedBooks.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("All Books")
                                        .font(.title3.bold())
                                        .padding(.horizontal)

                                    LazyVStack {
                                        ForEach(vm.feedBooks) { book in
                                            BookRowView(book: book)
                                                .padding(.horizontal)
                                            Divider().padding(.horizontal)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await vm.loadAll(token: authVM.token)
                    }
                }
            }
            .navigationTitle("Hello, \(authVM.user?.firstName ?? "") 👋")
            .task {
                await vm.loadAll(token: authVM.token)
            }
        }
    }
}

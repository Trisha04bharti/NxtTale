
import SwiftUI
import Lottie

struct HomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = HomeViewModel()
    @State private var showProfilePopup = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // ── Custom Header ──
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("NxtTale")
                                .font(.largeTitle.bold())
                            Text("Every Story Begins Somewhere")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Profile Circle
                        Button {
                            withAnimation(.spring()) {
                                showProfilePopup = true
                            }
                        } label: {
                            VStack(spacing: 4) {
                                ZStack {
                                    if let photo = authVM.user?.profilePhoto,
                                       let data  = Data(base64Encoded: photo),
                                       let uiImg = UIImage(data: data) {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    } else {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Text(authVM.user?.firstName.prefix(1) ?? "U")
                                                    .font(.headline.bold())
                                                    .foregroundColor(.blue)
                                            )
                                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                    }
                                }

                                Text(authVM.user?.username ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: 60)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // ── Lottie Reading Animation ──
                    HStack {
                        Spacer()
                        LottieView(animation: .named("reading"))
                            .playing(loopMode: .loop)
                            .frame(width: 180, height: 180)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // ── Recently Read ──
                    if !vm.recentlyRead.isEmpty {
                        RecentlyReadSectionView(books: vm.recentlyRead)
                    }

                    // ── Similar Sections ──
                    if !vm.similarSections.isEmpty {
                        ForEach(vm.similarSections) { section in
                            SimilarBooksSectionView(section: section)
                        }
                    }

                    // ── Picked For You ──
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

                    // ── Genre Categories ──
                    ForEach(vm.categories) { section in
                        CategorySectionView(section: section)
                    }

                    // ── All Books ──
                    if !vm.feedBooks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("All Books")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            LazyVStack(spacing: 0) {
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
            .navigationBarHidden(true)
            .refreshable {
                await vm.loadAll(token: authVM.token)
            }
            .task {
                await vm.loadAll(token: authVM.token)
            }
            .overlay {
                if showProfilePopup {
                    ProfilePopupView(isShowing: $showProfilePopup)
                        .environmentObject(authVM)
                        .transition(.opacity)
                }
            }

            if vm.isLoading && vm.feedBooks.isEmpty {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

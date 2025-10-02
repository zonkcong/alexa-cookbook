import SwiftUI
import AVKit

struct ReelsFeedView: View {
    @StateObject private var vm = ReelsViewModel()
    @EnvironmentObject private var theme: ThemeManager

    @State private var containerSize: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let safe = proxy.safeAreaInsets

            ZStack(alignment: .top) {
                if #available(iOS 17.0, *) {
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            ForEach(Array(vm.reels.enumerated()), id: \.1.id) { index, reel in
                                ReelPageView(
                                    reel: reel,
                                    player: vm.player(for: reel),
                                    isActive: index == vm.currentIndex,
                                    likeAction: { vm.toggleLike(for: reel) },
                                    commentAction: { vm.showComments = true },
                                    shareAction: { vm.showShare = true },
                                    audioAction: { vm.showAudioDetails = true },
                                    moreAction: { vm.showActions = true },
                                    followAction: { vm.toggleFollow(for: reel) },
                                    muteAction: { vm.toggleMute(for: reel) },
                                    playPauseAction: { vm.togglePlayPause() }
                                )
                                .containerRelativeFrame(.vertical)
                                .onAppear { vm.onAppear(index: index) }
                                .onDisappear { vm.onDisappear(index: index) }
                            }
                        }
                    }
                    .scrollTargetLayout()
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea(edges: .all)
                    .onScrollPhaseChange { old, new, transaction in
                        // When scroll stops (settled), pick the nearest index
                        if new == .idle {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                vm.playCurrent()
                            }
                        } else {
                            vm.pauseCurrent()
                        }
                    }
                } else {
                    // Fallback: simple TabView paging
                    TabView(selection: $vm.currentIndex) {
                        ForEach(Array(vm.reels.enumerated()), id: \.1.id) { index, reel in
                            ReelPageView(
                                reel: reel,
                                player: vm.player(for: reel),
                                isActive: index == vm.currentIndex,
                                likeAction: { vm.toggleLike(for: reel) },
                                commentAction: { vm.showComments = true },
                                shareAction: { vm.showShare = true },
                                audioAction: { vm.showAudioDetails = true },
                                moreAction: { vm.showActions = true },
                                followAction: { vm.toggleFollow(for: reel) },
                                muteAction: { vm.toggleMute(for: reel) },
                                playPauseAction: { vm.togglePlayPause() }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: vm.currentIndex) { _, newValue in
                        vm.handlePagingSettled(to: newValue)
                    }
                }

                ProgressBarView(progress: currentProgress)
                    .frame(height: 2)
                    .padding(.top, safe.top + 6)
                    .padding(.horizontal, 24)
            }
            .background(Color.black)
            .ignoresSafeArea()
            .onChange(of: vm.currentIndex) { _, newIndex in
                vm.handlePagingSettled(to: newIndex)
                Haptics.light()
            }
            .onAppear { vm.playCurrent() }
            .onChange(of: vm.showComments) { _, newVal in if newVal { Haptics.light() } }
            .onChange(of: vm.showShare) { _, newVal in if newVal { Haptics.light() } }
            .onChange(of: vm.showAudioDetails) { _, newVal in if newVal { Haptics.light() } }
            .onChange(of: vm.showActions) { _, newVal in if newVal { Haptics.light() } }
            .overlay(alignment: .top) {
                StatusBarOverlay()
                    .padding(.top, safe.top + 2)
                    .padding(.horizontal, 8)
            }
            .sheet(isPresented: $vm.showComments) {
                CommentsSheetView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $vm.showShare) {
                ShareSheetView()
                    .presentationDetents([.height(260)])
                    .presentationDragIndicator(.visible)
                    .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $vm.showAudioDetails) {
                AudioDetailsSheetView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $vm.showActions) {
                ActionSheetView()
                    .presentationDetents([.height(220)])
                    .presentationDragIndicator(.visible)
                    .background(.ultraThinMaterial)
            }
            .sheet(isPresented: $vm.showProfile) {
                ProfileView()
            }
            .alert("Video failed to load. Retry.", isPresented: $vm.showNetworkToast) {
                Button("Retry") { vm.playCurrent() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var currentProgress: Double {
        guard vm.reels.indices.contains(vm.currentIndex) else { return 0 }
        let reel = vm.reels[vm.currentIndex]
        return vm.observers[reel.id]?.progress ?? 0
    }
}

private struct ReelPageView: View {
    let reel: Reel
    let player: AVPlayer
    let isActive: Bool

    let likeAction: () -> Void
    let commentAction: () -> Void
    let shareAction: () -> Void
    let audioAction: () -> Void
    let moreAction: () -> Void
    let followAction: () -> Void
    let muteAction: () -> Void
    let playPauseAction: () -> Void

    @State private var showHeartBurst: Bool = false
    @State private var likeScale: CGFloat = 1.0
    @State private var isPausedHUDVisible: Bool = false
    @State private var isVolumeHUDVisible: Bool = false

    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .overlay(overlayControls)
                .onTapGesture(count: 2) {
                    likeAction()
                    burstHeart()
                    Haptics.light()
                }
                .onTapGesture {
                    isPausedHUDVisible = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        isPausedHUDVisible = false
                    }
                    playPauseAction()
                }
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.35).onEnded { _ in
                    // long-press action sheet (handled by parent through moreAction)
                    moreAction()
                })

            if isPausedHUDVisible {
                Image(systemName: "playpause.fill")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .transition(.opacity)
            }

            if isVolumeHUDVisible {
                Image(systemName: reel.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.ultraThinMaterial))
                    .transition(.opacity)
                    .offset(y: -120)
            }

            // Top/bottom fade gradients
            LinearGradient(colors: [Color.black.opacity(0.7), .clear], startPoint: .top, endPoint: .center)
                .ignoresSafeArea()
            LinearGradient(colors: [.clear, Color.black.opacity(0.7)], startPoint: .center, endPoint: .bottom)
                .ignoresSafeArea()

            if showHeartBurst {
                Image(systemName: "heart.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(.red)
                    .scaleEffect(likeScale)
                    .transition(.scale)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var overlayControls: some View {
        GeometryReader { proxy in
            let size = proxy.size
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    // Caption block with avatar, name, follow, caption, audio title
                    CaptionBlockView(
                        reel: reel,
                        followAction: followAction,
                        muteAction: {
                            withAnimation(.easeOut(duration: 0.2)) { isVolumeHUDVisible = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                withAnimation(.easeOut(duration: 0.2)) { isVolumeHUDVisible = false }
                            }
                            muteAction()
                        },
                        audioAction: audioAction
                    )
                }
                .frame(width: size.width * 0.72, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 24)

                Spacer()

                // Action rail
                ActionRailView(
                    likeAction: likeAction,
                    commentAction: commentAction,
                    shareAction: shareAction,
                    audioAction: audioAction,
                    moreAction: moreAction,
                    likeState: reel.isLiked,
                    likeCount: reel.likeCount,
                    commentCount: reel.commentCount
                )
                .padding(.trailing, 10)
                .padding(.bottom, 24)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func burstHeart() {
        showHeartBurst = true
        likeScale = 0.9
        withAnimation(.easeOut(duration: 0.12)) { likeScale = 1.12 }
        withAnimation(.easeOut(duration: 0.22).delay(0.12)) { likeScale = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.15)) {
                showHeartBurst = false
            }
        }
    }
}

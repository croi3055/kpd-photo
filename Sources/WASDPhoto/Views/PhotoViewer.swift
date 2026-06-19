import AppKit
import AVKit
import SwiftUI
import WASDPhotoCore

struct PhotoViewer: View {
    let photo: PhotoItem
    let strings: AppStrings

    var body: some View {
        if photo.kind.isVideo {
            VideoMediaView(url: photo.url)
                .padding(24)
        } else {
            Group {
                if let image = NSImage(contentsOf: photo.url) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                        Text(strings.unableToLoadImage)
                        Text(photo.fileName)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .id(photo.id)
        }
    }
}

private struct VideoMediaView: View {
    let url: URL
    @State private var player = AVPlayer()

    var body: some View {
        AppKitVideoPlayerView(url: url, player: player)
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .id(url)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
            }
            .onDisappear {
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
    }
}

private struct AppKitVideoPlayerView: NSViewRepresentable {
    let url: URL
    let player: AVPlayer

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .floating
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        let currentURL = (nsView.player?.currentItem?.asset as? AVURLAsset)?.url
        guard currentURL != url else {
            return
        }

        player.pause()
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        nsView.player = player
    }

    static func dismantleNSView(_ nsView: AVPlayerView, coordinator: ()) {
        nsView.player?.pause()
        nsView.player?.replaceCurrentItem(with: nil)
        nsView.player = nil
    }
}

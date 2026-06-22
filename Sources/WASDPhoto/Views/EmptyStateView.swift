import SwiftUI

struct EmptyStateView: View {
    let strings: AppStrings
    let openFolder: () -> Void
    let openDroppedItems: ([URL]) -> Void
    @State private var isDropTargeted = false
    private let outerPadding: CGFloat = 40
    private let dropZoneSize = CGSize(width: 300, height: 300)

    var body: some View {
        VStack {
            VStack(spacing: 14) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 44))
                    .foregroundStyle(isDropTargeted ? .blue : .secondary)

                Text(strings.dragFolderTitle)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(strings.dragFolderSubtitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 420)

                Button(strings.openFolder) {
                    openFolder()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(22)
            .frame(width: dropZoneSize.width, height: dropZoneSize.height)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isDropTargeted ? Color.blue : Color.secondary.opacity(0.25),
                        style: StrokeStyle(lineWidth: isDropTargeted ? 3 : 1, dash: [8, 7])
                    )
            }
            .onDrop(of: [.fileURL], isTargeted: $isDropTargeted, perform: handleDrop(providers:))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(outerPadding)
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        DroppedFileURLs.load(from: providers) { urls in
            guard !urls.isEmpty else {
                return
            }
            openDroppedItems(urls)
        }
    }
}

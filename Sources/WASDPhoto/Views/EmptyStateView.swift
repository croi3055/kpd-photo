import SwiftUI

struct EmptyStateView: View {
    let strings: AppStrings
    let openFolder: () -> Void
    let openDroppedItems: ([URL]) -> Void
    @State private var isDropTargeted = false

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 58))
                    .foregroundStyle(isDropTargeted ? .blue : .secondary)

                Text(strings.dragFolderTitle)
                    .font(.title2)
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
            .padding(28)
            .frame(maxWidth: 480)
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
        .padding()
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

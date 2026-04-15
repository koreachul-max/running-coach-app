import SwiftUI

struct MediaGalleryView: View {
    @ObservedObject var viewModel: RunningCoachViewModel
    @State private var showPicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    @State private var caption = ""
    @State private var shareItem: Any?
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Upload photo or video")) {
                        Button(action: { showPicker = true }) {
                            Text("Choose media")
                        }

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 240)
                                .cornerRadius(12)
                        }

                        if selectedVideoURL != nil {
                            Text("A video is selected and ready to save.")
                                .font(.subheadline)
                        }

                        TextField("Caption", text: $caption)

                        Button(action: saveMedia) {
                            Text("Save media")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }

                List(viewModel.mediaItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        if let image = item.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(10)
                        }

                        if let url = item.videoURL {
                            Text(url.lastPathComponent)
                                .font(.headline)
                        }

                        Text(item.caption)

                        HStack {
                            Spacer()
                            Button(action: { share(item: item) }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Media")
            .sheet(isPresented: $showPicker) {
                MediaPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareItem = shareItem {
                    ShareActivityView(activityItems: [shareItem])
                }
            }
        }
    }

    private func saveMedia() {
        guard selectedImage != nil || selectedVideoURL != nil else { return }
        viewModel.addMedia(image: selectedImage, videoURL: selectedVideoURL, caption: caption)
        selectedImage = nil
        selectedVideoURL = nil
        caption = ""
    }

    private func share(item: MediaItem) {
        if let image = item.image {
            shareItem = image
        } else if let url = item.videoURL {
            shareItem = url
        }
        showShareSheet = true
    }
}

struct MediaGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        MediaGalleryView(viewModel: RunningCoachViewModel())
    }
}

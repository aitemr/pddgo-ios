//
//  RoadSignChatView.swift
//  pdd
//
//  Camera → road-sign recognition chat. The user takes or selects a
//  photo; Akzhol's multimodal cloud backend returns the sign meaning.
//  (Option B from the road-sign plan — pure cloud vision, no local model.)
//

import SwiftUI
import PhotosUI
import UIKit

struct RoadSignChatView: View {
    @State private var vm = ChatViewModel()
    @State private var showPicker = false
    @State private var showCamera = false
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 0) {
            if vm.messages.isEmpty {
                introView
            } else {
                ChatView(vm: vm, showsCamera: true)
            }
        }
        .background(.white)
        .navigationTitle(L.roadsignTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.onLimitReached = { showPaywall = true } }
        .sheet(isPresented: $showPicker) {
            PhotoPicker { data in autoSend(imageData: data) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { data in autoSend(imageData: data) }
                .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPaywall) { PaywallView(canDismiss: true) }
    }

    // MARK: - Intro

    private var introView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)
            Image("akzhol")
                .resizable().scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .background(AppColor.brandBlue.opacity(0.12), in: Circle())
            Text(L.roadsignIntroTitle)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textBlack)
            Text(L.roadsignIntroSubtitle)
                .font(.system(size: 15, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black.opacity(0.6))
                .padding(.horizontal, 24)
            Spacer()
            VStack(spacing: 12) {
                actionButton(title: L.roadsignCameraBtn, icon: "camera.fill", background: AppColor.brandBlue) {
                    showCamera = true
                }
                actionButton(title: L.roadsignGalleryBtn, icon: "photo.on.rectangle", background: Color(hex: "#7B61FF")) {
                    showPicker = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func actionButton(title: String, icon: String, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                Text(title).font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(background, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Auto-send

    private func autoSend(imageData: Data) {
        vm.pendingImages = [imageData]
        vm.input = L.roadsignPromptText
        vm.send()
    }
}

// MARK: - Camera picker

/// Minimal UIImagePickerController wrapper for camera capture; returns
/// downsized JPEG data matching PhotoPicker's contract.
private struct CameraPicker: UIViewControllerRepresentable {
    var onPick: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        p.delegate = context.coordinator
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true)
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.7) else { return }
            parent.onPick(data)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

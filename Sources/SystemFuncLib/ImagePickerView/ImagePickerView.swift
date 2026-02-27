//
//  ImagePickerView.swift
//  UtilsSystemLib
//
//  Created by Nikolay Burkin on 26.02.2026.
//

import SwiftUI
import VisionKit
import Vision

// MARK: - Image Picker
@available(iOS 13.0, *)
public struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        
        public init(_ parent: ImagePicker) { self.parent = parent }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

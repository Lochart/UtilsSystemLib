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
public struct ImagePickerView: UIViewControllerRepresentable {
    
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
        
        let parent: ImagePickerView
        
        public init(_ parent: ImagePickerView) { self.parent = parent }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
    
    // MARK: - Image Picker & Vision OCR
    public func recognizeTextFromImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation], error == nil else {
                completion(nil)
                return
            }
            let texts = results.compactMap { $0.topCandidates(1).first?.string }
            let joined = texts.joined(separator: " ")
            completion(RegexFuncLib.extractCardNumber(from: joined))
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ru", "en"]
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

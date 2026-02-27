//
//  CardScannerView.swift
//  UtilsSystemLib
//
//  Created by Nikolay Burkin on 26.02.2026.
//

import SwiftUI
import VisionKit
import Vision

// MARK: - CardScannerView оптимизация и улучшения
@available(iOS 16.0, *)
struct CardScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        do {
            try scanner.startScanning()
        } catch {
            print("CardScannerView: startScanning() failed: \(error)")
        }
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    // MARK: - Image Picker & Vision OCR
    func recognizeTextFromImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
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
            completion(CardScannerView.extractCardNumber(from: joined))
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ru", "en"]
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // MARK: - Общий метод для извлечения номера
    static func extractCardNumber(from text: String) -> String? {
        if let number = text.firstMatch(regex: "\\d[\\d\\s]{7,}\\d") {
            return number.replacingOccurrences(of: " ", with: "")
        }
        return nil
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: CardScannerView
        init(_ parent: CardScannerView) {
            self.parent = parent
        }
        // Автоматический захват чисел при появлении
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd items: [RecognizedItem]) {
            for item in items {
                if case .text(let textItem) = item {
                    parent.handleRecognizedText(textItem)
                    break
                }
            }
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
                case .text(let textItem):
                    parent.handleRecognizedText(textItem, fallback: true)
                default:
                    break
            }
        }
    }
    
    // MARK: - Приватный метод для обработки текста
    func handleRecognizedText(_ textItem: RecognizedItem.Text, fallback: Bool = false) {
        // Используем свойство textItem.transcript для получения текста
        let transcript = textItem.transcript
        if let cleanNumber = CardScannerView.extractCardNumber(from: transcript) {
            scannedText = cleanNumber
        } else if fallback {
            scannedText = transcript
        }
        presentationMode.wrappedValue.dismiss()
    }
}

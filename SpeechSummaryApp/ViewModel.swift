//
//  ViewModel.swift
//  SpeechSummaryApp
//
//  Created by Mohandas Palatshaha on 12/08/24.
//


import SwiftUI
import AVFoundation
import CoreData

class ViewModel: ObservableObject {
    @Environment(\.managedObjectContext) private var viewContext

    @Published var transcribedText = ""
    @Published var summarizedText = ""
    @Published var isRecording = false

    private var audioRecorder: AVAudioRecorder?

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()

            isRecording = true
            print("Recording started")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("Recording stopped")
    }

    func summarizeText() {
        guard !transcribedText.isEmpty else {
            return
        }

        let apiKey = "YOUR_OPENAI_API_KEY"
        let url = URL(string: "https://api.openai.com/v1/completions")!
        let prompt = "Summarize the following text: \(transcribedText)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "max_tokens": 50
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let result = try? JSONDecoder().decode(OpenAIResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.summarizedText = result.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Summary unavailable"
                    }
                } else {
                    print("Failed to decode response")
                }
            } else if let error = error {
                print("Request failed with error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func saveData() {
        let newEntry = SpeechEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.date = Date()
        newEntry.transcription = transcribedText
        newEntry.summary = summarizedText
        newEntry.audioFileName = "recording.m4a"

        do {
            try viewContext.save()
            print("Data saved successfully.")
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        let text: String
    }
    let choices: [Choice]
}

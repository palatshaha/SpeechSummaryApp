//
//  ContentView.swift
//  SpeechSummaryApp
//
//  Created by Mohandas Palatshaha on 12/08/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel = ViewModel()

    @FetchRequest(
        entity: SpeechEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SpeechEntry.date, ascending: false)],
        animation: .default)
    private var speechEntries: FetchedResults<SpeechEntry>

    var body: some View {
        VStack {
            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            TextField("Transcribed Text", text: $viewModel.transcribedText)
                .padding()
                .border(Color.gray)

            Button(action: {
                viewModel.summarizeText()
            }) {
                Text("Summarize Text")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            TextField("Summary", text: $viewModel.summarizedText)
                .padding()
                .border(Color.gray)

            Button(action: {
                viewModel.saveData()
            }) {
                Text("Save Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            List {
                ForEach(speechEntries, id: \.id) { entry in
                    VStack(alignment: .leading) {
                        Text("Transcription: \(entry.transcription ?? "")")
                        Text("Summary: \(entry.summary ?? "")")
                    }
                }
            }
        }
        .padding()
    }
}

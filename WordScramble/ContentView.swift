//
//  ContentView.swift
//  WordScramble
//
//  Created by Jack Lingle on 12/5/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }.navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
        }
    }
    func addNewWord() {
        newWord = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard newWord.count > 0 else { return }
        withAnimation {
            usedWords.insert(newWord, at: 0)
        }
        newWord = ""
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return;
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
}

#Preview {
    ContentView()
}

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
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
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
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage)
                }
        }
    }
    func addNewWord() {
        newWord = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard newWord.count > 0 else { return }
        guard isOriginal(word: newWord) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: newWord) else {
            wordError(title: "Word not possible", message: "You cannot spell \(newWord) from \(rootWord)")
            return
        }
        guard isReal(word: newWord) else {
            wordError(title: "Word not recognized", message: "\(rootWord) is not a part of the english dictionary")
            return
        }
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
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos) // letter has been used so is now removed
            } else {
                return false
            }
        }
        return true
    }
    func isReal (word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}

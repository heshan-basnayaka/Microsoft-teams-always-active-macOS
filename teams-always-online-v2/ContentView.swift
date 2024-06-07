//
//  ContentView.swift
//  teams-always-online-v2
//
//  Created by Heshan Basnayaka on 2024-06-07.
//

import SwiftUI

struct ContentView: View {
    @State private var minutes: String = ""
    @State private var isRunning = false
    @State private var keepAwakeTask: DispatchWorkItem?

    var body: some View {
        VStack {
            Text("Enter minutes to keep the system awake:")
                .padding()
            
            TextField("Minutes", text: $minutes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: startKeepAwake) {
                    Text("Start")
                }
                .padding()
                .disabled(isRunning)
                
                Button(action: stopKeepAwake) {
                    Text("Stop")
                }
                .padding()
                .disabled(!isRunning)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 200)
    }
    
    func startKeepAwake() {
        guard let minutesInt = Int(minutes), minutesInt > 0 else {
            showAlert(message: "Incorrect input. You can only enter a numeric value greater than zero.")
            return
        }
        
        isRunning = true
        keepAwakeTask = DispatchWorkItem {
            for _ in 1...minutesInt {
                if self.keepAwakeTask?.isCancelled == true {
                    return
                }
                self.sendScrollLockKey()
                Thread.sleep(forTimeInterval: 60)
            }
            DispatchQueue.main.async {
                self.showAlert(message: "Forced awake time over. Back to normal routine.")
                self.isRunning = false
            }
        }
        
        if let task = keepAwakeTask {
            DispatchQueue.global().async(execute: task)
        }
    }
    
    func stopKeepAwake() {
        keepAwakeTask?.cancel()
        isRunning = false
        showAlert(message: "Awake process stopped.")
    }
    
    func sendScrollLockKey() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 71, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 71, keyDown: false)
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  FormScreen.swift
//  DemoApp
//
//  Created by Harshit Sharma on 22/10/24.
//

import SwiftUI
import Chat360Sdk

struct FormScreen: View {
    @State private var botId : String = ""
    @State private var appId : String = ""
    @State private var showBottomSheet: Bool = false
    @State private var metaKey: String = ""
    @State private var metaValue: String = ""
    @State private var metaEntries: [(key: String, value: String)] = []
    @State private var editingIndex: Int? = nil
    @State private var url: String = ""
    @State private var errorMessage: String? = nil

     var body: some View {
         ScrollView {
            
         VStack(spacing: 20) {
             Text("Chat360 Bot Demo")
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .padding(.bottom, 30)

             VStack(alignment: .leading) {
                 Text("Bot Id")
                     .font(.headline)
                     .foregroundColor(.gray)
                 TextField("Enter Bot ID", text: $botId)
                     .textFieldStyle(RoundedBorderTextFieldStyle())
                     .padding(.vertical, 8)
             }
             
             VStack(alignment: .leading) {
                 Text("App Id")
                     .font(.headline)
                     .foregroundColor(.gray)
                 TextField("Enter App ID", text: $appId)
                     .textFieldStyle(RoundedBorderTextFieldStyle())
                     .padding(.vertical, 8)
             }

             VStack(alignment: .leading) {
                 Text("Meta Data")
                     .font(.headline)
                     .foregroundColor(.gray)

                 HStack {
                     TextField("Key", text: $metaKey)
                         .textFieldStyle(RoundedBorderTextFieldStyle())
                         .padding(.vertical, 8)

                     TextField("Value", text: $metaValue)
                         .textFieldStyle(RoundedBorderTextFieldStyle())
                         .padding(.vertical, 8)

                     Button(action: {
                         if let index = editingIndex {
                             metaEntries[index] = (key: metaKey, value: metaValue)
                             editingIndex = nil
                         } else {
                             if !metaKey.isEmpty && !metaValue.isEmpty {
                                 metaEntries.append((key: metaKey, value: metaValue))
                             }
                         }
                         metaKey = ""
                         metaValue = ""
                     }) {
                         Image(systemName: editingIndex == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                             .foregroundColor(.blue)
                             .font(.title)
                     }
                 }

                 ForEach(metaEntries.indices, id: \.self) { index in
                     HStack {
                         Text("\(metaEntries[index].key): \(metaEntries[index].value)")
                             .foregroundColor(.black)

                         Spacer()

                         Button(action: {
                             editingIndex = index
                             metaKey = metaEntries[index].key
                             metaValue = metaEntries[index].value
                         }) {
                             Image(systemName: "pencil")
                                 .foregroundColor(.orange)
                         }

                         Button(action: {
                             if  editingIndex == nil && !metaEntries.isEmpty {

                                metaEntries.remove(at: index)
                             }
                         }) {
                             Image(systemName: "trash")
                                 .foregroundColor(.red)
                         }
                     }
                 }
             }
             
             // URL input section
                    VStack(alignment: .leading) {
                        Text("Extract Data from URL")
                            .font(.headline)
                            .foregroundColor(.gray)

                        HStack {
                            TextField("Enter URL", text: $url)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 8)

                            Button(action: {
                                extractData(from: url)
                            }) {
                                Text("Extract")
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }


             Button(action: {
                 do {
                     let config = Chat360Config(botId: botId, appId: appId, meta: Dictionary(uniqueKeysWithValues: metaEntries))
                     Chat360Bot.shared.setConfig(chat360Config: config)
                     try Chat360Bot.shared.startChatbot(animated: true)
                 } catch {
                     print("Failed to Load");
                 }
             }) {
                 Text("Launch Bot")
                     .font(.headline)
                     .padding()
                     .frame(maxWidth: .infinity)
                     .background(Color.blue)
                     .foregroundColor(.white)
                     .cornerRadius(8)
             }
             .padding(.top, 20)
            
         }
         .padding()
         .background(Color(UIColor.systemGroupedBackground))
         .cornerRadius(10)
         .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
         .padding()
     }
    }
    
    func extractData(from url: String) {
            guard let components = URLComponents(string: url),
                  let queryItems = components.queryItems else {
                errorMessage = "Invalid URL"
                return
            }

        for queryItem in queryItems {
            switch queryItem.name {
            case "h":
                botId = queryItem.value ?? ""
            case "appId":
                appId = queryItem.value ?? ""
            case "meta":
                // Handle meta data
                if let value = queryItem.value, let jsonData = value.data(using: .utf8) {
                    do {
                        // Decode the JSON string into a dictionary
                        let jsonEntries = try JSONDecoder().decode([String: String].self, from: jsonData)
                        // If you want to store entries in metaEntries
                        metaEntries.append(contentsOf: jsonEntries.map { ($0.key, $0.value) })
                    } catch {
                        print("Failed to decode JSON: \(error)")
                    }
                }
            default:
                break
            }
        }
            errorMessage = nil
        }
}

#Preview {
    FormScreen()
}

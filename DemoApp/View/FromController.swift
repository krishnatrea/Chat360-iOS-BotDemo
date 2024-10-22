//
//  FromController.swift
//  DemoApp
//
//  Created by Harshit Sharma on 22/10/24.
//

import Foundation
import Chat360Sdk

class FormController : ObservableObject {

    @Published var botUrl : String?
    @Published var botId : String?
    @Published var appId : String?
    @Published var meta: [String: String]?
    @Published var config : Chat360Config?
    
    func setupConfig() {
        guard botUrl != nil else {
            if((botId != nil || !botId!.isEmpty)) {
                config = Chat360Config(botId: botId!, appId: appId ?? "", meta: meta)
            }
            return;
        }
    }
    
    func fromUrl() -> String? {
        var url = URL(string: botUrl!)
        var query  = url?.query();
        return query;
    }
}

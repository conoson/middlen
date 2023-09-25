//
//  middlenApp.swift
//  middlen
//
//  Created by Kwon on 2023/09/18.
//

import SwiftUI

@main
struct middlenApp: App {
    let delegate = AppDelegate()
    
    init(){
        delegate.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

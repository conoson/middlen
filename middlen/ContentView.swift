//
//  ContentView.swift
//  middlen
//
//  Created by Kwon on 2023/09/18.
//

import SwiftUI

struct ContentView: View {
    @State private var isTapped = false
    
    var body: some View {
        VStack {
            Text("Trackpad Hook App")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

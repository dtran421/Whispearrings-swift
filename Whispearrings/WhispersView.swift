//
//  ContentView.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

struct WhispersView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            VStack {
                HStack {
                    Text("My Whispers")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding([.top, .leading], 10.0)
                WhispersList()
                    .font(.title)
            }
            .tabItem {
                VStack {
                    Image("first")
                    Text("My Whispers")
                }
            }
            .tag(0)
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image("second")
                        Text("Record")
                    }
                }
                .tag(1)
            Text("Third View")
            .font(.title)
            .tabItem {
                VStack {
                    Image("second")
                    Text("Explore")
                }
            }
            .tag(2)
            Text("Fourth View")
            .font(.title)
            .tabItem {
                VStack {
                    Image("second")
                    Text("Now Playing")
                }
            }
            .tag(3)
        }
    }
}

struct WhispersView_Previews: PreviewProvider {
    static var previews: some View {
        WhispersView()
    }
}

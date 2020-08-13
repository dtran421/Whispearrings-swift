//
//  LibraryView.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/4/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    @State var selectedFilter: String = "all"
        
    var filters: Array<String> = ["all", "defaults", "my whispers"]
    
    var body: some View {
        VStack {
            HStack {
                Text("library")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 15)
                Spacer()
            }
            .padding(.top, 20)
            HStack {
                ForEach (filters, id: \.self) { filter in
                    if selectedFilter == filter {
                        Button (action: {}, label: {
                            Text("\(filter)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.vertical, 3)
                        })
                        .disabled(true)
                        .background(Color.black)
                        .cornerRadius(40)
                    } else {
                        Button (action: {
                            selectedFilter = filter
                        }, label: {
                            Text("\(filter)")
                                .font(.headline)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.vertical, 3)
                        })
                        .background(Color.white)
                        .cornerRadius(40)
                    }
                }
                Spacer()
            }
            .padding([.leading, .top], 15)
            Spacer()
            ScrollView (showsIndicators: false) {
                VStack (spacing: 5) {
                    ForEach (whisperCollection.whispers, id: \.id) { whisper in
                        if (selectedFilter == "my whispers" && whisper.type == "User") || (selectedFilter == "defaults" && whisper.type == "Default") || selectedFilter == "all" {
                            LibraryCard(whisper: whisper, selectedFilter: selectedFilter)
                                .environmentObject(whisperCollection)
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, 5)
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

//
//  LibraryView.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/4/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

struct LibraryView: View {
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
                ForEach (whisperCollection.whispers, id: \.id) { whisper in
                    HStack {
                        if (selectedFilter == "my whispers" && whisper.type == "User") || (selectedFilter == "defaults" && whisper.type == "Default") || selectedFilter == "all" {
                            if whisper.type == "Default" {
                                Image("default")
                                    .resizable()
                                    .frame(width: 75, height: 75)
                                    .padding([.leading, .vertical], 10)
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .opacity(0.25)
                                    .frame(width: 80, height: 80)
                                    .padding([.leading, .vertical], 10)
                                    .overlay(
                                        Text("my whisper")
                                            .font(.callout)
                                            .multilineTextAlignment(.center)
                                            .padding(.leading, 10)
                                        , alignment: .center)
                            }
                            Text("\(whisper.value!)")
                                .foregroundColor(.black)
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .background(Color.white)
                }
                Spacer()
            }
            .padding(.top, 5)
            .padding(.horizontal, 15)
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}

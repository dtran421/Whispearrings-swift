//
//  CreateSheet.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/16/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import Combine

struct TimingSheet: View {
        
    @Binding var showTimingSheet: Bool
    
    @Binding var timing: Int
    @Binding var randomTiming: Bool
    @Binding var shufflePlay: Bool
    @Binding var repeatPlay: Bool
    
    var timings: Array<String>
        
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showTimingSheet.toggle()
                }) {
                    Text("DONE").fontWeight(.semibold).foregroundColor(Color.black)
                        .onTapGesture {
                            showTimingSheet.toggle()
                        }
                }
            }
            .padding([.top, .leading, .trailing])
            Image(systemName: "clock")
                .resizable()
                .frame(width: 32, height: 32, alignment: .center)
                .foregroundColor(.black)
            Text("how often do you want to hear whispers from the queue?")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10.0)
            Spacer()
            Text("whisper every:")
                .padding(.bottom, -10.0)
            Picker(selection: $timing, label: Text("")) {
                ForEach (0 ..< timings.count) { idx in
                    Text("\(timings[idx])").tag(idx)
                }
            }
            .padding(.top, -30.0)
            .labelsHidden()
            Spacer()
            HStack {
                Spacer()
                Text("Random Timing")
                    .font(.headline)
                    .fontWeight(.semibold)
                Toggle(isOn: $randomTiming) {}
                    .labelsHidden()
                Spacer()
            }
            .padding(.top, -5.0)
            Spacer()
            HStack {
                Spacer()
                VStack {
                    if shufflePlay {
                        Image(systemName: "shuffle")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.blue)
                        Text("shuffle")
                            .font(.headline)
                            .foregroundColor(Color.blue)
                    } else {
                        Image(systemName: "shuffle")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.black)
                        Text("shuffle")
                            .font(.headline)
                    }
                }
                .onTapGesture{
                    shufflePlay.toggle()
                }
                Spacer()
                VStack {
                    if repeatPlay {
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.blue)
                        Text("repeat")
                            .font(.headline)
                            .foregroundColor(Color.blue)
                    } else {
                        Image(systemName: "repeat")
                            .resizable()
                            .frame(width: 48, height: 48, alignment: .center)
                            .foregroundColor(.black)
                        Text("repeat")
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    repeatPlay.toggle()
                }
                Spacer()
            }
            .padding(.bottom, 50.0)
        }
        .background(Color.pink.opacity(0.15))
        .frame(maxHeight: .infinity)
    }
}

struct CreateSheet_Previews: PreviewProvider {
    static var previews: some View {
        //PreviewWrapper()
        /*TimingSheet(showTimingSheet: .constant(true), timing: .constant(2), randomTiming: .constant(false), shufflePlay: .constant(false), repeatPlay: .constant(false), timings: ["5 minutes", "15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours"])*/
        Text("test")
    }
    
    /*struct PreviewWrapper: View {
        @State(initialValue: true) var code: Bool
        @State(initialValue: 3) var code2: Int
        @State(initialValue: false) var code3: Bool
        @State(initialValue: false) var code4: Bool
        @State(initialValue: false) var code5: Bool

        var body: some View {
            TimingSheet(showTimingSheet: $code, timing: $code2, randomTiming: $code3, shufflePlay: $code4, repeatPlay: $code5)
        }
      }*/
}

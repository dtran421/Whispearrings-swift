//
//  LibraryCard.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/12/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import CoreData

struct LibraryCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    let whisper: Whisper
    
    let selectedFilter: String
    
    @State private var offset = CGFloat.zero
    
    let DRAG_MAX = CGFloat(125)
    let DRAG_THRESHOLD = CGFloat(50)
    
    var body: some View {
        ZStack {
            HStack() {
                Button(action: {
                    do {
                        let temp = try managedObjectContext.fetch(NSFetchRequest<QueueArray>(entityName: "QueueArray"))
                        
                        temp[0].addToQueue(whisper)
                                        
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    
                    do {
                        try managedObjectContext.save()
                        print("saved new queue!")
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    whisperCollection.fetchQueue()
                    
                    offset = CGFloat.zero
                }, label: {
                    Text("Add to Queue")
                        .font(.headline)
                        .foregroundColor(whisperCollection.queue.contains(whisper) ? .gray : .white)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                })
                .frame(maxWidth: abs(DRAG_MAX), maxHeight: .infinity)
                .background(whisperCollection.queue.contains(whisper) ? Color.orange : Color.green)
                .disabled(whisperCollection.queue.contains(whisper))
                Spacer()
            }
            HStack {
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
            .background(Color.white)
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: CGFloat(25))
                    .onChanged { gesture in
                        withAnimation(.easeOut) {
                            let width = gesture.translation.width
                            if width > 0 {
                                if offset + width > DRAG_MAX {
                                    offset = DRAG_MAX
                                } else {
                                    offset = width
                                }
                            } else {
                                if offset + width < 0 {
                                    offset = 0
                                } else {
                                    offset += (width / 5)
                                }
                            }
                        }
                    }

                    .onEnded { gesture in
                        withAnimation(.easeOut) {
                            if offset < DRAG_THRESHOLD {
                                offset = 0
                            } else {
                                offset = DRAG_MAX
                            }
                        }
                    }
            )
        }
    }
}

struct LibraryCard_Previews: PreviewProvider {
    static var previews: some View {
        //LibraryCard()
        Text("test")
    }
}

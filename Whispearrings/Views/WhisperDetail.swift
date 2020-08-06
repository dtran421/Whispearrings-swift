//
//  WhisperDetail.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/13/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import CoreData
import SwiftUI

struct WhisperDetail: View {
    var whisper: DefaultWhisper
    
    @State private var newTime = Date()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
    var body: some View {
        VStack {
            Text(whisper.value)
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 30)
            HStack {
                /*ForEach(whisper.times.sorted(), id: \.self) { time in
                    Text("\(time)")
                }*/
            }
            Spacer()
            HStack {
                DatePicker(selection: $newTime, displayedComponents: .hourAndMinute, label: { Text("Time") })
                    .frame(maxWidth: 50, maxHeight: 30)
                Button("Submit", action: {
                    let managedObjectContext = appDelegate.persistentContainer.viewContext

                    let time = Time(context: managedObjectContext)
                    
                    print(time)
                    
                })
                .padding(.leading, 50)
            }
            Spacer()
        }
    }
}

struct WhisperDetail_Previews: PreviewProvider {
    static var previews: some View {
        WhisperDetail(whisper: whisperData[0])
    }
}

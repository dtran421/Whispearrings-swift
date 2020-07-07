//
//  WhispersList.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

struct WhispersList: View {
    var body: some View {
        List(whisperData) { whisper in Whisper_Card(whisper: whisper)
        }
    }
}

struct WhispersList_Previews: PreviewProvider {
    static var previews: some View {
        WhispersList()
    }
}

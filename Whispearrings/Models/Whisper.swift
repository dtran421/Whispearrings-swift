//
//  Whisper.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

struct Whisper: Hashable, Codable, Identifiable {
    var id: Int
    var value: String
    var times: Array<String>
    fileprivate var user: String
}

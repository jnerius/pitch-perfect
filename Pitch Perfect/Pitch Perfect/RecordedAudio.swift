//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Josh Nerius on 3/28/15.
//  Copyright (c) 2015 Josh Nerius. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    init(filePathUrl : NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
    
    var filePathUrl: NSURL!
    var title: String!
}
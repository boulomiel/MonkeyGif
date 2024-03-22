//
//  File.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 21/03/2024.
//

import Foundation
import UIKit

extension UIImage {
    enum SF: String {
        case chevronLeft = "chevron.left"
        case camera = "camera"
        case star = "star"
    }
    
    convenience init(sf: SF) {
        self.init(systemName: sf.rawValue)!
    }
}

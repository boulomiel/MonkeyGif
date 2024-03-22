//
//  XibView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 22/03/2024.
//

import Foundation
import UIKit

class XibView: UIView {
    
    @IBOutlet weak var container: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        loadFromNib()
        addSubview(container)
    }
}

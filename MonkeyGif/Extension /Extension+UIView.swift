//
//  Extension+UIView.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation
import UIKit

extension UIView {
    static func animateBouncy(withDuration duration: TimeInterval, delay: TimeInterval = 0, damping: CGFloat = 0.5, velocity: CGFloat = 0.5, options: UIView.AnimationOptions = [], animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options, animations: animations, completion: completion)
    }
    
    func loadFromNib() {
        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self)
    }
}

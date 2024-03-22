//
//  GifViewCell.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import UIKit
import Combine
import SwiftyGif

class GifViewCell: UICollectionViewCell {
    
    static let identifier: String = "GifViewCell"
    
    @IBOutlet weak private (set) var gifImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.gifImageView.delegate = self
    }
    
    func setup(gifData : GifData) {
        let loader = UIActivityIndicatorView()
        loader.style = .medium
        if let url = URL(string: gifData.url) {
            self.gifImageView.setGifFromURL(url, customLoader: loader)
        } else {
            self.gifImageView.image = .init(sf: .camera)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifImageView.image = nil
    }
    
    static func toNib() -> UINib {
        UINib(nibName: String(describing: GifViewCell.self), bundle: nil)
    }
}

extension GifViewCell: SwiftyGifDelegate {
    
    func gifURLDidFinish(sender: UIImageView) {
        UIView.animateBouncy(withDuration: 0.3) {
            sender.layer.borderWidth = 1
            sender.layer.borderColor = UIColor.white.cgColor
            sender.layer.cornerRadius = 8
            sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        } completion: { _ in
            UIView.animateBouncy(withDuration: 0.5) {
                sender.transform = .identity
            }
        }
    }
}

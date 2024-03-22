//
//  DecoratorProtocol.swift
//  MonkeyGif
//
//  Created by Ruben Mimoun on 20/03/2024.
//

import Foundation

protocol DecoratorProtocol {
    associatedtype Holder
    var holder: Holder { get set }
    func setup()
}

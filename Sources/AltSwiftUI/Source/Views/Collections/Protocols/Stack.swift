//
//  Stack.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/11/04.
//

import UIKit

protocol Stack: AltView, Renderable {
    var viewContent: [AltView] { get }
    var subviewIsEquallySpaced: (AltView) -> Bool { get }
    var setSubviewEqualDimension: (UIView, UIView) -> Void { get }
    func updateView(_ view: UIView, context: Context, oldViewContent: [AltView]?)
}

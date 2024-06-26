//
//  Toggle.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

/// A view that can be turned on and off.
public struct Toggle: AltView {
    public var viewStore = ViewValues()
    let isOn: Binding<Bool>
    let label: AltView
    
    /// Creates an instance of a toggle.
    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> AltView) {
        self.isOn = isOn
        self.label = label()
    }
    public init(_ title: String, isOn: Binding<Bool>) {
        self.isOn = isOn
        label = Text(title)
    }
    public var body: AltView {
        EmptyView()
    }
}

extension Toggle: Renderable {
    public func createView(context: Context) -> UIView {
        let labelsHidden = context.viewValues?.labelsHidden ?? false
        let view = SwiftUISwitch().noAutoresizingMask()
        updateView(view, context: context)
        
        if labelsHidden {
            return view
        } else {
            return SwiftUILabeledView(label: label.renderableView(parentContext: context) ?? UIView(), control: view)
        }
    }
    
    public func updateView(_ view: UIView, context: Context) {
        if let view = view as? SwiftUISwitch {
            setupView(view, context: context)
        } else if let view = view as? SwiftUILabeledView<UIView, SwiftUISwitch> {
            label.scheduleUpdateRender(uiView: view.label, parentContext: context)
            setupView(view.control, context: context)
        }
    }
    
    private func setupView(_ view: SwiftUISwitch, context: Context) {
        view.isOnBinding = isOn
        view.isOn = isOn.wrappedValue
    }
}

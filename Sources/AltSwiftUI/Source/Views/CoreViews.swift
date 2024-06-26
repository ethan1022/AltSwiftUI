//
//  CoreViews.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/10/07.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

// MARK: - Renderable Views

/// An empty view with no content.
public struct EmptyView: AltView {
    public var viewStore = ViewValues()
    public var body: AltView {
        self
    }
    public init() {}
}

extension EmptyView: Renderable {
    public func updateView(_ view: UIView, context: Context) {
    }
    
    public func createView(context: Context) -> UIView {
        SwiftUIEmptyView().noAutoresizingMask()
    }
}

/// A view that adds padding to another view.
public struct PaddingView: AltView, Equatable {
    public static func == (lhs: PaddingView, rhs: PaddingView) -> Bool {
        if let lContent = lhs.contentView as? PaddingView, let rContent = rhs.contentView as? PaddingView {
            return lContent == rContent
        } else {
            return type(of: lhs.contentView) == type(of: rhs.contentView)
        }
    }
    
    public var viewStore = ViewValues()
    public var body: AltView {
        EmptyView()
    }
    var contentView: AltView
    var padding: CGFloat?
    var paddingInsets: EdgeInsets?
}

extension PaddingView: Renderable {
    public func createView(context: Context) -> UIView {
        let view = SwiftUIPaddingView().noAutoresizingMask()
        
        context.viewOperationQueue.addOperation {
            guard let renderedContentView = self.contentView.renderableView(parentContext: context, drainRenderQueue: false) else { return }
            view.content = renderedContentView
            self.setupView(view, context: context)
        }
        
        return view
    }
    
    public func updateView(_ view: UIView, context: Context) {
        guard let view = view as? SwiftUIPaddingView else { return }
        if let content = view.content {
            context.viewOperationQueue.addOperation {
                self.contentView.updateRender(uiView: content, parentContext: context, drainRenderQueue: false)
                self.setupView(view, context: context)
            }
        }
    }
    
    private func setupView(_ view: SwiftUIPaddingView, context: Context) {
        if let paddingInsets = paddingInsets {
            view.insets = UIEdgeInsets.withEdgeInsets(paddingInsets)
        } else if let padding = padding {
            view.insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
        if context.transaction?.animation != nil {
            view.setNeedsLayout()
        }
    }
}

// MARK: - Builder Views

public struct OptionalView: AltView {
    enum IfElseType: Equatable {
        /// Views inside 'if' statement
        case `if`
        /// Views inside 'else' statement
        case `else`
        /// View inside if statements. Used when views in multiple if/else levels
        /// are flattened. The `Int` value is used to uniquely identify each if/else block after
        /// flattening.
        case flattenedIf(Int)
        /// View inside else statements. Used when views in multiple if/else levels
        /// are flattened. The `Int` value is used to uniquely identify each if/else block after
        /// flattening.
        case flattenedElse(Int)
    }
    
    public var viewStore = ViewValues()
    public var body: AltView {
        EmptyView()
    }
    let content: [AltView]?
    var ifElseType: IfElseType?
}

public struct TupleView: AltView, ViewGrouper {
    public var viewStore = ViewValues()
    var viewContent: [AltView]
    
    public init(_ values: [AltView]) {
        viewContent = values
    }
    
    public var body: AltView {
        EmptyView()
    }
}

//
//  ViewBuilder.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/07/29.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import Foundation

/// A parameter and function attribute that can specify multiple views in the
/// form of a closure.
///
/// ViewBuilder is used when passing children views as parameter to a parent
/// view.
@_functionBuilder
public enum ViewBuilder {
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }
    
    public static func buildBlock(_ children: AltView) -> AltView {
        children
    }
    
    public static func buildBlock(_ c0: AltView, _ c1: AltView) -> TupleView {
        TupleView([c0, c1])
    }
    
    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView) -> TupleView {
        TupleView([c0, c1, c2])
    }

    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3])
    }
  
    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4])
    }

    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView, _ c5: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5])
    }

    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView, _ c5: AltView, _ c6: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6])
    }

    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView, _ c5: AltView, _ c6: AltView, _ c7: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7])
    }
 
    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView, _ c5: AltView, _ c6: AltView, _ c7: AltView, _ c8: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7, c8])
    }
 
    public static func buildBlock(_ c0: AltView, _ c1: AltView, _ c2: AltView, _ c3: AltView, _ c4: AltView, _ c5: AltView, _ c6: AltView, _ c7: AltView, _ c8: AltView, _ c9: AltView) -> TupleView {
        TupleView([c0, c1, c2, c3, c4, c5, c6, c7, c8, c9])
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` view
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf(_ content: AltView?) -> OptionalView {
        OptionalView(content: content?.subViews)
    }
    
    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither(first: AltView) -> AltView {
        OptionalView(content: first.subViews, ifElseType: .if)
    }
    
    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither(second: AltView) -> AltView {
        OptionalView(content: second.subViews, ifElseType: .else)
    }
}

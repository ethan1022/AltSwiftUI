//
//  ViewCollectionIteration.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2020/08/05.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

enum DiffableViewSourceOperation {
    case insert(view: AltView)
    case delete(view: AltView)
    case update(view: AltView)
}

enum DiffableDataSourceOperation<Data> {
    case insert(data: Data)
    case delete(data: Data)
    case update(data: Data)
}

enum CollectionDiffIndex {
    case current(index: Int)
    case old(index: Int)
}

extension Array where Element == AltView {
    
    /// Iterates through all direct views, flattening Groups.
    /// Iterated views have their parent properties merged.
    func flatIterate(viewValues: ViewValues = ViewValues(), action: (AltView) -> Void) {
        for view in self {
            let mergedValues = view.viewStore.merge(defaultValues: viewValues)
            if let group = view as? (ViewGrouper & AltView) {
                group.viewContent.flatIterate(viewValues: mergedValues, action: action)
            } else {
                var view = view
                view.viewStore = mergedValues
                action(view)
            }
        }
    }
    
    /// Iterates through all direct and indirect views.
    /// Iterated views have their parent properties merged.
    ///
    /// This is useful when you want to iterate through all final subviews, even if they
    /// exist in `ForEach` loops or marked as optional.
    func totallyFlatIterate(viewValues: ViewValues = ViewValues(), action: (AltView) -> Void) {
        for view in self {
            let mergedValues = view.viewStore.merge(defaultValues: viewValues)
            if let group = view as? (ViewGrouper & AltView) {
                group.viewContent.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else if let group = view as? OptionalView {
                group.content?.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else if let group = view as? ComparableViewGrouper {
                group.viewContent.totallyFlatIterate(viewValues: mergedValues, action: action)
            } else {
                var view = view
                view.viewStore = mergedValues
                action(view)
            }
        }
    }
    
    /// Iterates through all direct and indirect views and maintains optional view info.
    /// Iterated views have their parent properties merged. If iterated views are part of an
    /// `OptionalView`, a new `OptionalView` with same information will be created
    /// to host each view.
    ///
    /// This is useful when you want to iterate through all final subviews, even if they
    /// exist in `ForEach` loops or marked as optional.
    func totallyFlatIterateWithOptionalViewInfo(viewValues: ViewValues = ViewValues(), action: (AltView) -> Void) {
        totallyFlatIterateWithOptionalViewInfo(viewValues: viewValues, action: action, optionalIfBlockId: nil, optionalElseBlockId: nil)
    }
    
    /// Groups all views in sections.
    ///
    /// If a view is a `Section`, it won't
    /// be grouped. All other views that are not of `Section` type  will be sequentially
    /// grouped until the next view is a `Section`. Each view that is not a `Section`
    /// is not added to a `Section` directly, instead, resultant views from `View.totallyFlatSubViews`
    /// are used.
    func totallyFlatGroupedBySection() -> [Section] {
        var sections = [Section]()
        var temporalSection: Section?
        for view in self {
            if let section = view as? Section {
                if let unwrappedSection = temporalSection {
                    sections.append(unwrappedSection)
                    temporalSection = nil
                }
                sections.append(section)
            } else {
                if temporalSection == nil {
                    temporalSection = Section()
                }
                temporalSection?.viewContent.append(contentsOf: view.totallyFlatSubViews)
            }
        }
        
        if let temporalSection = temporalSection {
            sections.append(temporalSection)
        }
        
        return sections
    }
    
    /// Iterates each view totally flatly and calls the iteration
    /// closure. Groups are not flattened, and are expected to already be
    /// flattened.
    func iterateFullViewInsert(iteration: (AltView) -> Void) {
        for subView in self {
            if let optionalView = subView as? OptionalView {
                if let optionalViewContent = optionalView.content {
                    optionalViewContent.iterateFullViewInsert(iteration: iteration)
                }
            } else if let comparableGroupView = subView as? ComparableViewGrouper {
                comparableGroupView.viewContent.iterateFullViewInsert(iteration: iteration)
            } else {
                iteration(subView)
            }
        }
    }
    
    /// Iterates each view totally flatly and specifies what operations
    /// happen between the diff of an old list and a current list.
    ///
    /// The iteration returns:
    /// - index: The index in the UIView hierarchy to apply the operation to
    /// - operation: The operation that should happen at this index
    /// - currentView: The value of the current view, if it exists
    /// - oldView: The value of the old view, if it exists
    ///
    /// Groups are not flattened, and are expected to already be
    /// flattened.
    func iterateFullViewDiff(oldList: [AltView] = [], iteration: (Int, DiffableViewSourceOperation) -> Void) {
        var displayIndex = 0
        let maxCount = Swift.max(count, oldList.count)
        if maxCount == 0 {
            return
        }
        
        for index in 0..<maxCount {
            var subView: AltView?
            var oldView: AltView?
            if count > index {
                subView = self[index]
            }
            if oldList.count > index {
                oldView = oldList[index]
            }
            iterateFullSubviewDiff(subView: subView, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
        }
    }
    
    private func totallyFlatIterateWithOptionalViewInfo(viewValues: ViewValues = ViewValues(), action: (AltView) -> Void, optionalIfBlockId: Int?, optionalElseBlockId: Int?, ifElseType: OptionalView.IfElseType? = nil) {
        var optionalIfBlockId = optionalIfBlockId
        var optionalElseBlockId = optionalElseBlockId
        var ifElseType = ifElseType
        for view in self {
            let mergedValues = view.viewStore.merge(defaultValues: viewValues)
            if let group = view as? (ViewGrouper & AltView) {
                group.viewContent.totallyFlatIterateWithOptionalViewInfo(
                    viewValues: mergedValues,
                    action: action,
                    optionalIfBlockId: optionalIfBlockId,
                    optionalElseBlockId: optionalElseBlockId)
            } else if let group = view as? OptionalView {
                if group.ifElseType == .if {
                    var ifIdValue = 0
                    if let optionalIfIdValue = optionalIfBlockId {
                        ifIdValue = optionalIfIdValue + 1
                    } else {
                        ifIdValue = 0
                    }
                    optionalIfBlockId = ifIdValue
                    ifElseType = .flattenedIf(ifIdValue)
                } else if group.ifElseType == .else {
                    var elseIdValue = 0
                    if let optionalElseIdValue = optionalElseBlockId {
                        elseIdValue = optionalElseIdValue + 1
                    } else {
                        elseIdValue = 0
                    }
                    optionalElseBlockId = elseIdValue
                    ifElseType = .flattenedElse(elseIdValue)
                }
                group.content?.totallyFlatIterateWithOptionalViewInfo(
                    viewValues: mergedValues,
                    action: action,
                    optionalIfBlockId: optionalIfBlockId,
                    optionalElseBlockId: optionalElseBlockId,
                    ifElseType: ifElseType)
            } else if let group = view as? ComparableViewGrouper {
                group.viewContent.totallyFlatIterateWithOptionalViewInfo(
                    viewValues: mergedValues,
                    action: action,
                    optionalIfBlockId: optionalIfBlockId,
                    optionalElseBlockId: optionalElseBlockId)
            } else {
                var view = view
                view.viewStore = mergedValues
                if let ifElseType = ifElseType {
                    view = OptionalView(content: [view], ifElseType: ifElseType)
                }
                action(view)
            }
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func iterateFullSubviewDiff(subView: AltView?, oldView: AltView?, iteration: (Int, DiffableViewSourceOperation) -> Void, displayIndex: inout Int) {
        if let optionalView = subView as? OptionalView, let optionalViewContent = optionalView.content {
            let oldOptionalView = oldView as? OptionalView
            let maxCount = Swift.max(optionalViewContent.count, oldOptionalView?.content?.count ?? 0)
            if let newIfElseType = optionalView.ifElseType,
               let oldIfElseType = oldOptionalView?.ifElseType,
               newIfElseType != oldIfElseType {
                // If / else replacement
                iterateFullSubviewDiff(subView: nil, oldView: oldOptionalView, iteration: iteration, displayIndex: &displayIndex)
                iterateFullSubviewDiff(subView: optionalView, oldView: nil, iteration: iteration, displayIndex: &displayIndex)
            } else {
                // Optional insert / update
                for i in 0..<maxCount {
                    let subView = optionalViewContent[safe: i]
                    let oldSubView = oldOptionalView?.content?[safe: i]
                    iterateFullSubviewDiff(subView: subView, oldView: oldSubView, iteration: iteration, displayIndex: &displayIndex)
                }
            }
            
            // Normal delete
            if let oldView = oldView, oldOptionalView == nil {
                iterateFullSubviewDiff(subView: nil, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
            }
        } else if let oldOptionalView = oldView as? OptionalView, let oldOptionalViewContent = oldOptionalView.content {
            // Optional delete
            for oldSubView in oldOptionalViewContent {
                iterateFullSubviewDiff(subView: nil, oldView: oldSubView, iteration: iteration, displayIndex: &displayIndex)
            }
            // Optional delete + normal insert
            if let subView = subView, !(subView is OptionalView) {
                iterateFullSubviewDiff(subView: subView, oldView: nil, iteration: iteration, displayIndex: &displayIndex)
            }
        } else if subView is OptionalView && oldView is OptionalView {
            // Both Optional empty
            return
        } else if let comparableGroupView = subView as? ComparableViewGrouper {
            if let oldComparableGroupView = oldView as? ComparableViewGrouper {
                // ForEach update
                comparableGroupView.iterateDiff(oldViewGroup: oldComparableGroupView, startDisplayIndex: &displayIndex, iterate: iteration)
            } else {
                // ForEach insert
                for comparableSubview in comparableGroupView.viewContent {
                    iteration(displayIndex, .insert(view: comparableSubview))
                    displayIndex += 1
                }
                // Normal Delete
                if let oldView = oldView, !(oldView is OptionalView) {
                    iterateFullSubviewDiff(subView: nil, oldView: oldView, iteration: iteration, displayIndex: &displayIndex)
                }
            }
        } else if let oldComparableGroupView = oldView as? ComparableViewGrouper {
            // ForEach delete
            for comparableSubview in oldComparableGroupView.viewContent {
                iteration(displayIndex, .delete(view: comparableSubview))
                displayIndex += 1
            }
            // Normal insert
            if let subView = subView, !(subView is OptionalView) {
                iterateFullSubviewDiff(subView: subView, oldView: nil, iteration: iteration, displayIndex: &displayIndex)
            }
        } else {
            if let subView = subView {
                if let oldView = oldView {
                    // Normal update
                    if let padSubView = subView as? PaddingView, let padOldView = oldView as? PaddingView {
                        if padSubView == padOldView {
                            iteration(displayIndex, .update(view: subView))
                        } else {
                            iteration(displayIndex, .delete(view: oldView))
                            displayIndex += 1
                            iteration(displayIndex, .insert(view: subView))
                        }
                        displayIndex += 1
                    } else if type(of: subView) == type(of: oldView) {
                        iteration(displayIndex, .update(view: subView))
                        displayIndex += 1
                    } else {
                        if !(oldView is OptionalView) {
                            iteration(displayIndex, .delete(view: oldView))
                            displayIndex += 1
                        }
                        if !(subView is OptionalView) {
                            iteration(displayIndex, .insert(view: subView))
                            displayIndex += 1
                        }
                        return
                    }
                } else {
                    // Normal insert
                    if !(subView is OptionalView) {
                        iteration(displayIndex, .insert(view: subView))
                        displayIndex += 1
                    }
                }
            } else if let oldView = oldView {
                // Normal delete
                if !(oldView is OptionalView) {
                    iteration(displayIndex, .delete(view: oldView))
                    displayIndex += 1
                }
            }
        }
    }
}

extension RandomAccessCollection {
    /// Iterates and specifies the operation to apply the current
    /// collection's data to the `oldData`.
    /// - Parameters:
    ///   - oldData: The previos collection
    ///   - id: The keypath to use to get the id of an element in the collection
    ///   - startIndex: A base index to offset the operation index
    ///   - iteration: Closure called for each operation iteration
    func iterateDataDiff<OldData, ID>(oldData: OldData, id: (Element) -> ID, startIndex: Int = 0, dynamicIndex: Bool = true, iteration: (Int, CollectionDiffIndex, DiffableDataSourceOperation<Element>) -> Void)
    where OldData: RandomAccessCollection, OldData.Element == Element, ID: Hashable {
        let currentCount = count
        let oldCount =  oldData.count
        if currentCount == 0 && oldCount == 0 {
            return
        }
        var startIndex = startIndex
        
        var oldIndex = 0
        var currentIndex = 0
        while oldIndex < oldCount || currentIndex < currentCount {
            let currentElement = element(for: currentIndex)
            let oldElement = oldData.element(for: oldIndex)
            
            if let oldElement = oldElement, let currentElement = currentElement {
                let currentId = id(currentElement)
                let oldId = id(oldElement)
                let oldContainsCurrent = oldData.containsId(currentId, idFetcher: id)
                let currentContainsOld = containsId(oldId, idFetcher: id)
                if currentId == oldId || (oldContainsCurrent && currentContainsOld) {
                    // Place swap
                    iteration(startIndex, .current(index: currentIndex), .update(data: currentElement))
                    oldIndex += 1
                    currentIndex += 1
                    startIndex += 1
                } else if oldContainsCurrent {
                    // Delete item
                    iteration(startIndex, .old(index: oldIndex), .delete(data: oldElement))
                    oldIndex += 1
                    startIndex += 1
                } else {
                    // New item
                    iteration(startIndex, .current(index: currentIndex), .insert(data: currentElement))
                    currentIndex += 1
                    if dynamicIndex {
                        startIndex += 1
                    }
                }
            } else if let currentElement = currentElement {
                // New item
                iteration(startIndex, .current(index: currentIndex), .insert(data: currentElement))
                oldIndex += 1
                currentIndex += 1
                if dynamicIndex {
                    startIndex += 1
                }
            } else if let oldElement = oldElement {
                // Delete item
                iteration(startIndex, .old(index: oldIndex), .delete(data: oldElement))
                oldIndex += 1
                currentIndex += 1
                startIndex += 1
            } else {
                break
            }
        }
    }
    
    func element(for numberIndex: Int) -> Element? {
        if numberIndex >= count {
            return nil
        }
        
        let dataIndex = index(startIndex, offsetBy: numberIndex)
        return self[dataIndex]
    }
    
    func containsId<ID: Hashable>(_ id: ID, idFetcher: (Element) -> ID) -> Bool {
        contains { idFetcher($0) == id }
    }
}

extension UIView {
    func firstNonRemovingSubview(index: Int) -> (uiView: UIView, skippedSubViews: Int)? {
        var movingIndex = index
        while subviews.count > movingIndex {
            let uiView = subviews[movingIndex]
            if !(uiView.isAnimatingRemoval ?? false) {
                return (uiView: uiView, skippedSubViews: movingIndex - index)
            }
            movingIndex += 1
        }
        return nil
    }
}

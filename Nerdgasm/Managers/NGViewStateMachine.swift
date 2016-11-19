//
//  ViewStateMachine.swift
//  StatefulViewController
//
//  Created by Alexander Schuch on 30/07/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//
import UIKit
import RxCocoa
import RxSwift


/// Represents the state of the view state machine
public enum NGViewStateMachineState : Equatable {
    case none			// No view shown
    case view(String)	// View with specific key is shown
}

public func == (lhs: NGViewStateMachineState, rhs: NGViewStateMachineState) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.view(let lName), .view(let rName)): return lName == rName
    default: return false
    }
}
// state: ViewStateMachineState, animated: Bool = true, completion: (() -> ())? = nil
public typealias NGViewStateInput = (NGViewStateMachineState, Bool, (() -> ())?)
///
/// A state machine that manages a set of views.
///
/// There are two possible states:
///		* Show a specific placeholder view, represented by a key
///		* Hide all managed views
///
public class NGViewStateMachine {
    fileprivate var viewStore: [String: UIView]
    fileprivate let queue = DispatchQueue(label: "com.aschuch.viewStateMachine.queue", attributes: [])
    
    /// The view that should act as the superview for any added views
    public let view: UIView
    
    /// The current display state of views
    fileprivate let _currentState = Variable<NGViewStateMachineState>(.none)
    
    /// The last state that was enqueued
    fileprivate let _lastState = Variable<NGViewStateMachineState>(.none)
    
    public let currentState: Driver<NGViewStateMachineState>
    public let lastState: Driver<NGViewStateMachineState>
    
    fileprivate let disposeBag = DisposeBag()
    // MARK: Init
    
    ///  Designated initializer.
    ///
    /// - parameter view:		The view that should act as the superview for any added views
    /// - parameter states:		A dictionary of states
    ///
    /// - returns:			A view state machine with the given views for states
    ///
    public init(view: UIView, statesInput: Driver<NGViewStateInput>, states: [String: UIView]?) {
        self.view = view
        viewStore = states ?? [String: UIView]()
        self.currentState = _currentState.asDriver()
        self.lastState = _lastState.asDriver()

        statesInput
            .drive(onNext: { (input) -> Void in
                print("Transition ot state \(input.0)")
                self.transitionToState(stateInput: input)
                return Void()
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
    }
    
    /// - parameter view:		The view that should act as the superview for any added views
    ///
    /// - returns:			A view state machine
    ///
    public convenience init(view: UIView, statesInput: Driver<NGViewStateInput>) {
        self.init(view: view, statesInput: statesInput, states: nil)
    }
    
    
    // MARK: Add and remove view states
    
    /// - returns: the view for a given state
    public func viewForState(_ state: String) -> UIView? {
        return viewStore[state]
    }
    
    /// Associates a view for the given state
    public func addView(_ view: UIView, forState state: String) {
        viewStore[state] = view
    }
    
    ///  Removes the view for the given state
    public func removeViewForState(_ state: String) {
        viewStore[state] = nil
    }
    
    
    // MARK: Subscripting
    
    public subscript(state: String) -> UIView? {
        get {
            return viewForState(state)
        }
        set(newValue) {
            if let value = newValue {
                addView(value, forState: state)
            } else {
                removeViewForState(state)
            }
        }
    }
    
    
    // MARK: Switch view state
    
    /// Adds and removes views to and from the `view` based on the given state.
    /// Animations are synchronized in order to make sure that there aren't any animation gliches in the UI
    ///
    /// - parameter state:		The state to transition to
    /// - parameter animated:	true if the transition should fade views in and out
    /// - parameter campletion:	called when all animations are finished and the view has been updated
    ///
    fileprivate func transitionToState(stateInput: NGViewStateInput) {
        _lastState.value = stateInput.0
        queue.async {
            if stateInput.0 == self._currentState.value {
                return
            }
            
            // Suspend the queue, it will be resumed in the completion block
            self.queue.suspend()
            self._currentState.value = stateInput.0
            
            let c: () -> () = {
                self.queue.resume()
                stateInput.2?()
            }
            
            // Switch state and update the view

            DispatchQueue.main.sync {
                switch stateInput.0 {
                case .none:
                    self.hideAllViews(animated: stateInput.1, completion: c)
                case .view(let viewKey):
                    self.showView(state: viewKey, animated: stateInput.1, completion: c)
                }
            }
        }
    }
    
    
    // MARK: Private view updates
    
    fileprivate func showView(state: String, animated: Bool, completion: (() -> ())? = nil) {
        if let newView = self.viewStore[state] {
            // Add new view using AutoLayout
            newView.alpha = animated ? 0.0 : 1.0
            newView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(newView)
            
            let insets = (newView as? NGStatefulPlaceholderView)?.placeholderViewInsets() ?? UIEdgeInsets()
            let metrics = ["top": insets.top, "bottom": insets.bottom, "left": insets.left, "right": insets.right]
            let views = ["view": newView]
            
            let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-left-[view]-right-|", options: [], metrics: metrics, views: views)
            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-top-[view]-bottom-|", options: [], metrics: metrics, views: views)
            self.view.addConstraints(hConstraints)
            self.view.addConstraints(vConstraints)
        }
        
        let animations: () -> () = {
            if let newView = self.viewStore[state] {
                newView.alpha = 1.0
            }
        }
        
        let animationCompletion: (Bool) -> () = { (finished) in
            for (key, view) in self.viewStore {
                if !(key == state) {
                    view.removeFromSuperview()
                }
            }
            
            completion?()
        }
        
        animateChanges(animated: animated, animations: animations, completion: animationCompletion)
    }
    
    fileprivate func hideAllViews(animated: Bool, completion: (() -> ())? = nil) {
        let animations: () -> () = {
            for (_, view) in self.viewStore {
                view.alpha = 0.0
            }
        }
        
        let animationCompletion: (Bool) -> () = { (finished) in
            for (_, view) in self.viewStore {
                view.removeFromSuperview()
            }
            
            completion?()
        }
        
        animateChanges(animated: animated, animations: animations, completion: animationCompletion)
    }
    
    fileprivate func animateChanges(animated: Bool, animations: @escaping () -> (), completion: ((Bool) -> Void)?) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
        } else {
            completion?(true)
        }
    }
}

///
/// A state machine that manages a set of views by adding the state's view to a managed container view.
///
/// There are two possible states:
///		* Show a specific placeholder view, represented by a key
///		* Hide all managed views
///
public class NGContainerViewStateMachine: NGViewStateMachine {
    
    private let containerSuperview: UIView
    
    public override init(view: UIView, statesInput: Driver<NGViewStateInput>, states: [String: UIView]?) {
        self.containerSuperview = view
        
        let containerView = StateViewContainerView(frame: self.containerSuperview.frame)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.backgroundColor = UIColor.clear
        containerView.layer.zPosition = self.containerSuperview.layer.zPosition + 1.0
        
        super.init(view: containerView, statesInput: statesInput, states: states)
    }
    
    fileprivate override func showView(state: String, animated: Bool, completion: (() -> ())?) {
        self.view.frame = self.containerSuperview.frame
        self.containerSuperview.addSubview(self.view)
        
        super.showView(state: state, animated: animated, completion: completion)
    }
    
    fileprivate override func hideAllViews(animated: Bool, completion: (() -> ())?) {
        super.hideAllViews(animated: animated) {
            completion?()
            self.view.removeFromSuperview()
        }
    }
}

private class StateViewContainerView: UIView {
    
    private override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in self.subviews {
            if !view.isHidden && view.alpha > 0 && view.isUserInteractionEnabled &&
                view.point(inside: self.convert(point, to:view), with:event) {
                return true
            }
        }
        return false
    }
    
}

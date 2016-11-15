import UIKit
import RxCocoa
import RxSwift


// MARK: Default Implementation BackingViewProvider
extension NGBackingViewProviderType where Self: UIViewController {
    public var backingView: UIView{
        return view
    }
}

extension NGBackingViewProviderType where Self: UIView {
    public var backingView: UIView {
        return self
    }
}


// MARK: Default Implementation StatefulViewController
/// Default implementation of StatefulViewController for UIViewController
extension NGStatefulViewControllerType {
    
    public var stateMachine: NGViewStateMachine {
        return associatedObject(self, key: &stateMachineKey) { [unowned self] in
            let input = Driver.of(self.errorInput, self.contentInput, self.emptyInput, self.loadingInput).merge()
                .distinctUntilChanged({ (first, second) -> Bool in
                    return first.0 == second.0
                })
                .map{ (s, b, c) -> (NGViewStateMachineState, Bool, (() -> ())?) in
                    var sm: NGViewStateMachineState!
                    switch s {
                    case .Content:
                        sm = NGViewStateMachineState.none
                    default:
                        sm = .view(s.rawValue)
                    }
                    return (sm, b, c)
            }
            return NGViewStateMachine(view: self.backingView, statesInput: input)
        }
    }
    
    public var currentState: Driver<NGStatefulViewControllerState> {
        return stateMachine.currentState
            .map { machineState -> NGStatefulViewControllerState in
                switch machineState {
                case .none: return .Content
                case .view(let viewKey): return NGStatefulViewControllerState(rawValue: viewKey)!
            }
        }
    }
    
    public var lastState: Driver<NGStatefulViewControllerState> {
        return stateMachine.lastState
            .map{ machineState -> NGStatefulViewControllerState in
                switch machineState {
                case .none: return .Content
                case .view(let viewKey): return NGStatefulViewControllerState(rawValue: viewKey)!
            }
        }
    }
    
    // MARK: Views
    
    public var loadingView: UIView? {
        get { return placeholderView(.Loading) }
        set { setPlaceholderView(newValue, forState: .Loading) }
    }
    
    public var errorView: UIView? {
        get { return placeholderView(.Error) }
        set { setPlaceholderView(newValue, forState: .Error) }
    }
    
    public var emptyView: UIView? {
        get { return placeholderView(.Empty) }
        set { setPlaceholderView(newValue, forState: .Empty) }
    }
    
    
    fileprivate func placeholderView(_ state: NGStatefulViewControllerState) -> UIView? {
        return stateMachine[state.rawValue]
    }
    
    fileprivate func setPlaceholderView(_ view: UIView?, forState state: NGStatefulViewControllerState) {
        stateMachine[state.rawValue] = view
    }
}

extension NGStatefulViewControllerType where Self: UITableViewController {
    public var stateMachine: NGViewStateMachine {
        return associatedObject(self, key: &tableViewControllerStateContainerViewKey) { [unowned self] in
            let input = Driver.of(self.errorInput, self.contentInput, self.emptyInput, self.loadingInput).merge()
                .distinctUntilChanged({ (first, second) -> Bool in
                    return first.0 == second.0
                })
                .map{ (s, b, c) -> (NGViewStateMachineState, Bool, (() -> ())?) in
                    var sm: NGViewStateMachineState!
                    switch s {
                    case .Empty:
                        sm = NGViewStateMachineState.none
                    default:
                        sm = .view(s.rawValue)
                    }
                    return (sm, b, c)
            }
            return NGContainerViewStateMachine(view: self.backingView, statesInput: input)
        }
    }
}

private var stateMachineKey: UInt8 = 0
private var tableViewControllerStateContainerViewKey: UInt8 = 1

private func associatedObject<T: AnyObject>(_ host: AnyObject, key: UnsafeRawPointer, initial: () -> T) -> T {
    var value = objc_getAssociatedObject(host, key) as? T
    if value == nil {
        value = initial()
        objc_setAssociatedObject(host, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
    return value!
}

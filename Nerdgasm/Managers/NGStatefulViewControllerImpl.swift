import UIKit
import RxCocoa
import RxSwift


// MARK: Default Implementation BackingViewProvider
extension NGBackingViewProviderType where Self: UIViewController {
    public var backingView: Driver<UIView> {
        return Driver<UIView>.just(view)
    }
}

extension NGBackingViewProviderType where Self: UIView {
    public var backingView: Driver<UIView> {
        return Driver<UIView>.just(self)
    }
}


// MARK: Default Implementation StatefulViewController
/// Default implementation of StatefulViewController for UIViewController
extension NGStatefulViewControllerType {
    
    public var stateMachine: NGViewStateMachine {
        let input = Driver.of(self.errorInput, self.contentInput, self.emptyInput, self.loadingInput).merge()
                .map{ (s, b, c) -> (NGViewStateMachineState, Bool, (() -> ())?) in
                    var sm: NGViewStateMachineState!
                    switch s {
                    case .Empty:
                        sm = .none
                    default:
                        sm = .view(s.rawValue)
                    }
                    return (sm, b, c)
                }
        return NGViewStateMachine(view: backingView, statesInput: input)
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

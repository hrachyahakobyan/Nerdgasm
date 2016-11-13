import RxCocoa
import RxSwift

/// Represents all possible states of a stateful view controller
public enum NGStatefulViewControllerState: String {
    case Content = "content"
    case Loading = "loading"
    case Error = "error"
    case Empty = "empty"
}

/// Protocol to provide a backing view for that stateful view controller
public protocol NGBackingViewProviderType {
    /// The backing view, usually a UIViewController's view.
    /// All placeholder views will be added to this view instance.
    var backingView: Driver<UIView> { get }
}

public typealias NGStatefulViewControllerStateInput = (NGStatefulViewControllerState, Bool, (() -> ())?)

/// StatefulViewController protocol may be adopted by a view controller or a view in order to transition to
/// error, loading or empty views.
public protocol NGStatefulViewControllerType: class, NGBackingViewProviderType {
    /// The view state machine backing all state transitions
    var stateMachine: NGViewStateMachine { get }
    
    /// The current transition state of the view controller.
    /// All states other than `Content` imply that there is a placeholder view shown.
    var currentState: Driver<NGStatefulViewControllerState> { get }
    
    /// The last transition state that was sent to the state machine for execution.
    /// This does not imply that the state is currently shown on screen. Transitions are queued up and
    /// executed in sequential order.
    var lastState: Driver<NGStatefulViewControllerState> { get }
    
    var contentInput: Driver<NGStatefulViewControllerStateInput> { get }
    var loadingInput: Driver<NGStatefulViewControllerStateInput> { get }
    var errorInput: Driver<NGStatefulViewControllerStateInput> { get }
    var emptyInput: Driver<NGStatefulViewControllerStateInput> { get }
    
    // MARK: Views
    
    /// The loading view is shown when the `startLoading` method gets called
    var loadingView: UIView? { get set }
    
    /// The error view is shown when the `endLoading` method returns an error
    var errorView: UIView? { get set }
    
    /// The empty view is shown when the `hasContent` method returns false
    var emptyView: UIView? { get set }
    
    var handleError: ((Error) -> ())? { get }
   
}

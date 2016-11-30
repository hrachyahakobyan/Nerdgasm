import RxCocoa
import RxSwift
import Moya
import Gloss
import Result
import Foundation

typealias NGPagesResult = Result<[NGPage], NGNetworkError>

class NGPagesViewModel: NGViewModelType {
    
    typealias T = [NGPage]
    let results: Driver<NGPagesResult>
    let loading: Driver<Bool>
    private let query: Driver<String>
    
    init(category:Driver<NGCategory>, query: Driver<String>, reloadAction: Driver<Void>){
        let networking = NGNetworking.sharedNetworking
        self.query = query
        let searching = ActivityIndicator()
        self.loading = searching.asDriver()
        
        results = reloadAction.withLatestFrom(category)
            .flatMapLatest{ category in
                return networking.request(NGService.GetCategoryPages(categoryID: category.id))
                    .filterSuccessfulStatusCodes()
                    .mapJSONDataArray()
                    .map { jsons -> [NGPage] in
                        [NGPage].from(jsonArray: jsons) ?? []
                    }
                    .mapToFailable()
                    .trackActivity(searching)
                    .asDriver(onErrorJustReturn: .failure(NGNetworkError.NoConnection))
        }
    }
    
    func clean() -> Driver<T> {
        return Driver.combineLatest(results, query, resultSelector: { ($0, $1) })
            .filter{ (res, q) in
                guard case Result<T, NGNetworkError>.success(_) = res else {
                    return false
                }
                return true
            }
            .map{try! ($0.dematerialize(), $1)}
            .map{ (ts, query) in
                return ts.filter{ query.isEmpty || $0.title.lowercased().range(of: query.lowercased()) != nil }
        }
    }
}

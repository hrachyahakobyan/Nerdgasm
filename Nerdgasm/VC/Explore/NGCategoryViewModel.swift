import RxCocoa
import RxSwift
import Moya
import Gloss
import Result
import Foundation

typealias NGCategoryResult = Result<[NGCategory], NGNetworkError>

class NGCategoryViewModel: NGViewModelType {
    
    typealias T = [NGCategory]
    let results: Driver<NGCategoryResult>
    let loading: Driver<Bool>
    private let query: Driver<String>
    
    init(query: Driver<String>, reloadAction: Driver<Void>){
        let networking = NGNetworking.sharedNetworking
        self.query = query
        let searching = ActivityIndicator()
        self.loading = searching.asDriver()
        
        results = reloadAction
            .flatMapLatest{ _ in
                return networking.request(NGService.GetCategories)
                    .filterSuccessfulStatusCodes()
                    .mapJSONDataArray()
                    .map { jsons -> [NGCategory] in
                        let data = [NGCategory].from(jsonArray: jsons) ?? []
                        print(data)
                        return data
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

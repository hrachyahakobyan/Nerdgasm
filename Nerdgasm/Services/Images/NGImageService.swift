//
//  ImageService.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

enum DownloadableImage{
    case content(image:UIImage)
    case offlinePlaceholder
}

protocol ImageService {
    func imageFromURL(_ url: URL) -> Driver<(DownloadableImage, URL)>
}

class DefaultImageService: ImageService {
    
    static let sharedImageService = DefaultImageService() // Singleton
    
    // 1st level cache
    private let _imageCache = NSCache<AnyObject, AnyObject>()
    
    // 2nd level cache
    private let _imageDataCache = NSCache<AnyObject, AnyObject>()
    
    //private let _reachAbilityService = try! DefaultReachabilityService.init()
    
    let loadingImage = ActivityIndicator()
    
    private init() {
        // cost is approx memory usage
        _imageDataCache.totalCostLimit = 10 * 1024 * 1024
        
        _imageCache.countLimit = 20
    }
    
    private func decodeImage(_ imageData: Data) -> Observable<UIImage> {
        return Observable.just(imageData)
            .map { data in
                guard let image = UIImage(data: data) else {
                    throw NGNetworkError.Unknown
                }
                return image.forceLazyImageDecompression()
        }
    }
    
    private func _imageFromURL(_ url: URL) -> Observable<UIImage> {
        return Observable.deferred {
            let maybeImage = self._imageCache.object(forKey: url as AnyObject) as? UIImage
            
            let decodedImage: Observable<UIImage>
            
            // best case scenario, it's already decoded an in memory
            if let image = maybeImage {
                decodedImage = Observable.just(image)
            }
            else {
                let cachedData = self._imageDataCache.object(forKey: url as AnyObject) as? Data
                
                // does image data cache contain anything
                if let cachedData = cachedData {
                    decodedImage = self.decodeImage(cachedData)
                }
                else {
                    // fetch from network
                    decodedImage = URLSession.shared.rx.data(request: URLRequest(url: url))
                        .do(onNext: { data in
                            self._imageDataCache.setObject(data as AnyObject, forKey: url as AnyObject)
                        })
                        .flatMap(self.decodeImage)
                        .trackActivity(self.loadingImage)
                }
            }
            
            return decodedImage.do(onNext: { image in
                self._imageCache.setObject(image, forKey: url as AnyObject)
            })
        }
    }
    
    /**
     Service that tries to download image from URL.
     
     In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
     available.
     
     After image is sucessfully downloaded, sequence is completed.
     */
    func imageFromURL(_ url: URL) -> Driver<(DownloadableImage, URL)> {
        return _imageFromURL(url)
            .map { (DownloadableImage.content(image: $0), url) }
            //.retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: _reachAbilityService)
            .asDriver(onErrorJustReturn: (.offlinePlaceholder, url))
            .startWith((.offlinePlaceholder, url))
    }
}

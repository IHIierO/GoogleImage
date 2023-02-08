//
//  GIAPICacheManager.swift
//  GoogleImage
//
//  Created by Artem Vorobev on 08.02.2023.
//

import Foundation

/// Manager in memory session scoped API caches
final class GIAPICacheManager {
    // API URL: Data
    
    private var cacheDictionary: [GIEndpoint: NSCache<NSString, NSData>] = [:]
    
    private var cache = NSCache<NSString, NSData>()
    
    init() {
        setupCache()
    }
    
    // MARK: - Public
    
    public func cacheResponse(for endpoint: GIEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return nil
        }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    public func setCache(for endpoint: GIEndpoint, url: URL?, data: Data){
        guard let targetCache = cacheDictionary[endpoint], let url = url else {
            return
        }
        let key = url.absoluteString as NSString
        targetCache.setObject(data as NSData, forKey: key)
    }
    
    // MARK: - Private
    private func setupCache() {
        GIEndpoint.allCases.forEach({ endpoint in
            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
        })
    }
}

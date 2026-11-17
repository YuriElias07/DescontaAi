//
//  WishlistService.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import Foundation

extension Notification.Name {
    static let wishlistDidChange = Notification.Name("wishlistDidChange")
}

final class WishlistService {
    static let shared = WishlistService()
    
    private(set) var items: [Product] = [] {
        didSet {
            NotificationCenter.default.post(name: .wishlistDidChange, object: nil)
        }
    }
    
    private init() {}
    
    func add(_ product: Product) {
        guard !items.contains(where: { $0.id == product.id }) else { return }
        items.append(product)
    }
    
    func remove(_ product: Product) {
        items.removeAll { $0.id == product.id }
    }
    
    func contains(_ product: Product) -> Bool {
        items.contains { $0.id == product.id }
    }
    
    func clear() {
        items.removeAll()
    }
    
    var total: Double {
        items.reduce(0) { $0 + $1.price }
    }
}

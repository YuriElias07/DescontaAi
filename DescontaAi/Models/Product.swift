//
//  Product.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

struct Product: Decodable {
    let id: Int
    let title: String
    let price: Double
    let discountPercentage: Double
    let thumbnail: String
    let images: [String]?
    let description: String
    let category: String?
}

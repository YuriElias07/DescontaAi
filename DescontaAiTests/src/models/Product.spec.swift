//
//  DescontaAi_Tests.swift
//  DescontaAiTests
//
//  Created by Yuri Elias on 10/11/26.
//

import Testing
import UIKit

@testable import DescontaAi

struct DescontaAi_Tests {

    @Test func decodesProductsResponse() throws {
        let jsonString = """
        { "products": [ { "id": 1, "title": "Fone", "price": 99.9,
          "discountPercentage": 12.5, "thumbnail": "x", "description": "d",
          "category": "eletronics" } ] }
        """

        let data = Data(jsonString.utf8)
        let response = try JSONDecoder().decode(ProductsResponse.self, from: data)

        #expect(response.products.count == 1)
        #expect(response.products.first?.title == "Fone")
        #expect(response.products.first?.price == 99.9)
        #expect(response.products.first?.discountPercentage == 12.5)
    }

}

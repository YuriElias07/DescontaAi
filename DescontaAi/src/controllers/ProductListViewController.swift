//
//  ProductListViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import UIKit

class ProductListViewController: UIViewController {

    private let service: ProductServiceProtocol = ProductService()

    override func viewDidLoad() {
        super.viewDidLoad()

        service.fetchProducts { result in
            switch result {
            case .success(let products):
                print(products.count)
            case .failure(let error):
                print(error)
            }
        }
    }
}

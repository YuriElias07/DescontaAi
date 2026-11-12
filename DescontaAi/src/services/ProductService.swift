//
//  ProductService.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)
}

final class ProductService: ProductServiceProtocol {

    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/products") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            // deu erro de rede?
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            // veio corpo na resposta?
            guard let data else { return }

            // tenta virar [Product]
            do {
                let response = try JSONDecoder().decode(ProductsResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(response.products)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

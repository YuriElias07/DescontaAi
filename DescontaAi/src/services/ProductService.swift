//
//  ProductService.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import Foundation

/// protocolo de contrato para ter esta function e retornar valores reais
protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void)
}

final class ProductService: ProductServiceProtocol {

    /// somente o que são hardware.
    private let hardwareCategories: Set<String> = [
        "laptops",
        "smartphones",
        "tablets",
        "mobile-accessories"
    ]

    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        // limit=0 traz todos os 194, sem isso a API devolveria so 30
        guard let url = URL(string: "https://dummyjson.com/products?limit=0") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            
            /// caso dê error, ele pega o error vindo da prop criada na closure da URLSession
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data else {
                print("Sem dados para exibirb")
                return
            }

            do {
                let response = try JSONDecoder().decode(ProductsResponse.self, from: data)
                let hardware = response.products.filter {
                    self.hardwareCategories.contains($0.category)
                }
                DispatchQueue.main.async { completion(.success(hardware)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

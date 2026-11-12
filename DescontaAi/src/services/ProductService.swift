//
//  ProductService.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import Foundation

/// enum de errors possíveis para a request
enum ProductServiceError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
}

/// o que a nossa request deve retornar, no caso, os objetos do JSON que vem caso a request for feita com sucesso
/// ou os possíveis erros do enum de tipos de erros
protocol ProductServiceProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], ProductServiceError>) -> Void)
}

// de fato a chamada da API, porém nela tem 3 metódos
final class ProductService: ProductServiceProtocol {

/// 1 - fetchProducts() -> faz a chamada de fato da API
    func fetchProducts(completion: @escaping (Result<[Product], ProductServiceError>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            deliver(.failure(.invalidURL), completion: completion)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            self?.processResponse(data: data, error: error, completion: completion)
        }.resume()
    }

/// 2 - processResponse() -> trato os objetos que recebemos da requisição
    private func processResponse(
        data: Data?,
        error: Error?,
        completion: @escaping (Result<[Product], ProductServiceError>) -> Void
    ) {
        if let error {
            deliver(.failure(.network(error)), completion: completion)
            return
        }

        guard let data else {
            deliver(.failure(.network(URLError(.badServerResponse))), completion: completion)
            return
        }

        do {
            let response = try JSONDecoder().decode(ProductsResponse.self, from: data)
            deliver(.success(response.products), completion: completion)
        } catch {
            deliver(.failure(.decoding(error)), completion: completion)
        }
    }

/// 3. deliver() -> garante a main thread 
    private func deliver(
        _ result: Result<[Product], ProductServiceError>,
        completion: @escaping (Result<[Product], ProductServiceError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

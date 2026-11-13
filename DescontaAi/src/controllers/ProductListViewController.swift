//
//  ProductListViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import UIKit

final class ProductListViewController: UIViewController {

    private let service: ProductServiceProtocol = ProductService()
    private var products: [Product] = []

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "DescontaAí"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadProducts()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func loadProducts() {
        service.fetchProducts { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let products):
                self.products = products
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ProductListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ProductCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)

        let product = products[indexPath.row]
        cell.textLabel?.text = product.title
        cell.detailTextLabel?.text = "\(product.price)"
        return cell
    }
}

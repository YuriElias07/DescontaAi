//
//  ProductListViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import UIKit

final class ProductListViewController: UIViewController {
/// estados da tela
    enum ViewState {
        case loading
        case loaded
        case error(message: String)
        case empty
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    let errorLabel = UILabel()
    let retryButton = UIButton(type: .system)
    
    private let service: ProductServiceProtocol = ProductService()
    private var products: [Product] = []

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "DescontaAi"
        view.backgroundColor = .systemBackground
        setupTableView()
        loadProducts()
    }
    /// toda vez que muda a state, automaticamente deve chamar o updateUI()
    private var state: ViewState = .loading {
         didSet { updateUI() }
     }
    
    /// usando o enum de estados possiveis da tela
    private func updateUI() {
        switch state {
            
        case .loading:
            activityIndicator.startAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = true
            retryButton.isHidden = true
    
        case .loaded:
            activityIndicator.stopAnimating()
            tableView.isHidden = false
            errorLabel.isHidden = true
            retryButton.isHidden = true
    
        case .error(let message):
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = message
            retryButton.isHidden = false
    
        case .empty:
            activityIndicator.stopAnimating()
            tableView.isHidden = true
            errorLabel.isHidden = false
            errorLabel.text = "Nenhum produto encontrado"
            retryButton.isHidden = true
        }
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
                self.products = products.sorted(by: { $0.discountPercentage > $1.discountPercentage })
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

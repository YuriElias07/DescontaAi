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
            tableView.reloadData()
    
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
        
        // Adiciona as outras views
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Centraliza o spinner
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Centraliza a label de erro
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Botão abaixo da label
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12)
        ])
        
        tableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.rowHeight = 84
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 84, bottom: 0, right: 0)

        retryButton.setTitle("Tentar Novamente", for: .normal)
        retryButton.addTarget(self, action: #selector(loadProducts), for: .touchUpInside)
    }

   @objc private func loadProducts() {
        service.fetchProducts { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let products):
                self.products = products.sorted(by: { $0.discountPercentage > $1.discountPercentage })
                self.state = .loaded
            case .failure:
                self.state = .error(message: "Error ao carregar produtos.")
            }
        }
    }
}

extension ProductListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ProductCell", 
            for: indexPath
        ) as? ProductCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        
        cell.titleLabel.text = product.title
        cell.priceLabel.text = "R$ \(String(format: "%.2f", product.price))"
        cell.discountLabel.text = "-\(Int(product.discountPercentage))%"
        
        return cell
    }
}

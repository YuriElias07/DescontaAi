//
//  WishlistViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import UIKit

final class WishlistViewController: UIViewController {
    private let tableView = UITableView()
    private let toolbar = UIToolbar()
    private let totalLabel = UILabel()
    private let emptyLabel = UILabel()
    
    private var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Carrinho"
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupTableView()
        setupToolbar()
        setupEmptyLabel()
        loadProducts()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(wishlistDidChange),
            name: .wishlistDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Limpar",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WishlistCell.self, forCellReuseIdentifier: "WishlistCell")
        tableView.rowHeight = 84
    }
    
    private func setupToolbar() {
        view.addSubview(toolbar)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        totalLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        totalLabel.textAlignment = .center
        
        let labelItem = UIBarButtonItem(customView: totalLabel)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, labelItem, flexSpace]
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }
    
    private func setupEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "Carrinho vazio"
        emptyLabel.font = .systemFont(ofSize: 18, weight: .medium)
        emptyLabel.textColor = .systemGray
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadProducts() {
        products = WishlistService.shared.items
        updateUI()
    }
    
    private func updateUI() {
        tableView.reloadData()
        updateTotal()
        
        let isEmpty = products.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
    }
    
    private func updateTotal() {
        let total = WishlistService.shared.total
        totalLabel.text = "Total: R$ \(String(format: "%.2f", total))"
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: "Limpar carrinho",
            message: "Deseja remover todos os itens?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Limpar", style: .destructive) { _ in
            WishlistService.shared.clear()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func wishlistDidChange() {
        loadProducts()
    }
}

extension WishlistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "WishlistCell",
            for: indexPath
        ) as? WishlistCell else {
            return UITableViewCell()
        }
        
        let product = products[indexPath.row]
        cell.configure(with: product)
        return cell
    }
}

extension WishlistViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let product = products[indexPath.row]
            WishlistService.shared.remove(product)
        }
    }
}

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
    private var emptyStateView: EmptyStateView?
    private var products: [Product] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Sacola"
        view.backgroundColor = DesignSystem.background
        setupNavigationBar()
        setupToolbar()
        setupTableView()
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

    // MARK: - Layout

    private func setupNavigationBar() {
        let close = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        close.hidesSharedBackground = true

        let clear = UIBarButtonItem(
            title: "Limpar",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )
        clear.hidesSharedBackground = true

        navigationItem.leftBarButtonItem = close
        navigationItem.rightBarButtonItem = clear
    }

    private func setupTableView() {
        tableView.backgroundColor = DesignSystem.background
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WishlistCell.self, forCellReuseIdentifier: WishlistCell.identifier)
        tableView.rowHeight = 92
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
    }

    private func setupToolbar() {
        totalLabel.font = DesignSystem.number(20)
        totalLabel.textColor = DesignSystem.ink
        totalLabel.textAlignment = .center

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let totalItem = UIBarButtonItem(customView: totalLabel)
        totalItem.hidesSharedBackground = true
        toolbar.items = [flexSpace, totalItem, flexSpace]
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Dados

    private func loadProducts() {
        products = WishlistService.shared.items
        tableView.reloadData()

        totalLabel.text = "Total: \(DesignSystem.price(WishlistService.shared.total))"

        let isEmpty = products.isEmpty
        tableView.isHidden = isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty

        if isEmpty {
            showEmptyState()
        } else {
            emptyStateView?.removeFromSuperview()
            emptyStateView = nil
        }
    }

    private func showEmptyState() {
        guard emptyStateView == nil else { return }

        let emptyView = EmptyStateView(
            icon: "bag",
            title: "Sua sacola está vazia",
            message: "Toque na sacola de um produto para guardar a oferta aqui."
        )
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)

        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])

        emptyStateView = emptyView
    }

    // MARK: - Ações

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func clearTapped() {
        let alert = UIAlertController(
            title: "Limpar sacola",
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

// MARK: - UITableViewDataSource

extension WishlistViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WishlistCell.identifier,
            for: indexPath
        ) as? WishlistCell else { return UITableViewCell() }

        cell.configure(with: products[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WishlistViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(
            ProductDetailViewController(product: products[indexPath.row]),
            animated: true
        )
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            WishlistService.shared.remove(products[indexPath.row])
        }
    }
}

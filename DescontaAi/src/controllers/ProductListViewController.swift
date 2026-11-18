//
//  ProductListViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 11/11/26.
//

import UIKit

final class ProductListViewController: UIViewController {

    enum ViewState {
        case loading
        case loaded
        case error
        case empty
    }

    private let service: ProductServiceProtocol = ProductService()
    private var products: [Product] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let cartButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DesignSystem.background
        setupHeader()
        setupTableView()
        setupLoadingViews()
        loadProducts()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(wishlistDidChange),
            name: .wishlistDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private var state: ViewState = .loading {
        didSet { updateUI() }
    }

    // MARK: - Layout

    private func setupHeader() {
        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text = "DescontaAí"
        titleLabel.font = DesignSystem.text(24, weight: .bold)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)

        cartButton.setImage(UIImage(systemName: "bag.fill"), for: .normal)
        cartButton.tintColor = DesignSystem.ink
        cartButton.backgroundColor = DesignSystem.yellow
        cartButton.layer.cornerRadius = 22
        cartButton.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        cartButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(cartButton)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: DesignSystem.margin),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),

            cartButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -DesignSystem.margin),
            cartButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            cartButton.widthAnchor.constraint(equalToConstant: 44),
            cartButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = DesignSystem.background
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(HeroDealCell.self, forCellReuseIdentifier: HeroDealCell.identifier)
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoadingViews() {
        activityIndicator.color = DesignSystem.blue

        messageLabel.font = DesignSystem.text(15)
        messageLabel.textColor = DesignSystem.gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        retryButton.setTitle("Tentar de novo", for: .normal)
        retryButton.setTitleColor(DesignSystem.blue, for: .normal)
        retryButton.titleLabel?.font = DesignSystem.text(15, weight: .semibold)
        retryButton.addTarget(self, action: #selector(loadProducts), for: .touchUpInside)

        let views = [activityIndicator, messageLabel, retryButton]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),

            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: - Estados

    private func updateUI() {
        activityIndicator.stopAnimating()
        tableVisible(false)
        messageLabel.isHidden = true
        retryButton.isHidden = true

        switch state {
        case .loading:
            activityIndicator.startAnimating()
        case .loaded:
            tableVisible(true)
        case .error:
            messageLabel.text = "Não deu para carregar as ofertas.\nConfira sua conexão."
            messageLabel.isHidden = false
            retryButton.isHidden = false
        case .empty:
            messageLabel.text = "Nenhuma oferta por aqui agora."
            messageLabel.isHidden = false
        }
    }

    private func tableVisible(_ visible: Bool) {
        tableView.isHidden = !visible
        if visible {
            tableView.reloadData()
        }
    }

    // MARK: - Sacola

    @objc private func cartTapped() {
        let wishlistVC = WishlistViewController()
        present(UINavigationController(rootViewController: wishlistVC), animated: true)
    }

    @objc private func wishlistDidChange() {
        updateCartIcon()
    }

    private func updateCartIcon() {
        let name = WishlistService.shared.items.isEmpty ? "bag" : "bag.fill"
        cartButton.setImage(UIImage(systemName: name), for: .normal)
    }

    // MARK: - Dados

    @objc private func loadProducts() {
        state = .loading

        service.fetchProducts { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let products) where products.isEmpty:
                self.products = []
                self.state = .empty
            case .success(let products):
                self.products = products.sorted { $0.discountPercentage > $1.discountPercentage }
                self.state = .loaded
            case .failure:
                self.state = .error
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ProductListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard !products.isEmpty else { return 0 }
        return products.count > 1 ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return max(0, products.count - 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = indexPath.section == 0 ? products[0] : products[indexPath.row + 1]

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: HeroDealCell.identifier,
                for: indexPath
            ) as? HeroDealCell
            cell?.configure(with: product)
            return cell ?? UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductCell.identifier,
            for: indexPath
        ) as? ProductCell
        cell?.configure(with: product)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 else { return nil }

        let header = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Todas as ofertas"
        titleLabel.font = DesignSystem.text(15, weight: .semibold)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: DesignSystem.margin),
            titleLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -10)
        ])
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 1 ? 48 : 0
    }
}

// MARK: - UITableViewDelegate

extension ProductListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = indexPath.section == 0 ? products[0] : products[indexPath.row + 1]
        navigationController?.pushViewController(
            ProductDetailViewController(product: product),
            animated: true
        )
    }
}

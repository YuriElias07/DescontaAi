//
//  ProductDetailViewController.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import UIKit

final class ProductDetailViewController: UIViewController {
    private let product: Product
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let productImageView = UIImageView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let discountLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detalhes"
        setupNavigationBar()
        setupViews()
        configure()
        
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
        updateCartButton()
    }
    
    private func updateCartButton() {
        let isInWishlist = WishlistService.shared.contains(product)
        let iconName = isInWishlist ? "cart.fill" : "cart"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: iconName),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
    }
    
    @objc private func cartTapped() {
        if WishlistService.shared.contains(product) {
            WishlistService.shared.remove(product)
        } else {
            WishlistService.shared.add(product)
        }
    }
    
    @objc private func wishlistDidChange() {
        updateCartButton()
    }
    
    private func setupViews() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // StackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(stackView)
        
        // Configura subviews
        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .systemFont(ofSize: 14, weight: .medium)
        categoryLabel.textColor = .secondaryLabel
        
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        
        priceLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        
        discountLabel.font = .systemFont(ofSize: 14, weight: .bold)
        discountLabel.textColor = .white
        discountLabel.textAlignment = .center
        discountLabel.layer.cornerRadius = 4
        discountLabel.clipsToBounds = true
        
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        
        // Adiciona ao stackView
        stackView.addArrangedSubview(productImageView)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(titleLabel)
        
        // Container horizontal para preço + desconto
        let priceStackView = UIStackView(arrangedSubviews: [priceLabel, discountLabel])
        priceStackView.axis = .horizontal
        priceStackView.spacing = 12
        priceStackView.alignment = .center
        stackView.addArrangedSubview(priceStackView)
        
        stackView.addArrangedSubview(descriptionLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // StackView
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Imagem com altura fixa
            productImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Desconto com tamanho mínimo
            discountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            discountLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func configure() {
        categoryLabel.text = product.category.capitalized
        titleLabel.text = product.title
        priceLabel.text = "R$ \(String(format: "%.2f", product.price))"
        discountLabel.text = "-\(Int(product.discountPercentage))%"
        discountLabel.backgroundColor = product.discountPercentage >= 15 ? .systemRed : .systemOrange
        descriptionLabel.text = product.description
        
        // Carrega a imagem (usa primeira de images ou thumbnail)
        let imageURL = product.images?.first ?? product.thumbnail
        ImageLoader.loadImage(from: imageURL) { [weak self] image in
            self?.productImageView.image = image
        }
    }
}

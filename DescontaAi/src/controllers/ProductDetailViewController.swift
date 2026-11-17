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
    private let imageView = UIImageView()
    private let discountLabel = UILabel()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()
    private let addButton = UIButton(type: .system)

    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = DesignSystem.background
        title = "Detalhes"
        setupAddButton()
        setupScrollView()
        setupImage()
        setupCategory()
        setupInfo()
        configure() 

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(wishlistDidChange),
            name: .wishlistDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = DesignSystem.ink
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -12),

            stackView.topAnchor.constraint(equalTo: content.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: DesignSystem.margin),
            stackView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -DesignSystem.margin),
            stackView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: frame.widthAnchor, constant: -DesignSystem.margin * 2)
        ])
    }

    private func setupImage() {
        let imageContainer = UIView()

        imageView.backgroundColor = DesignSystem.white
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 26
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(imageView)

        discountLabel.text = DesignSystem.discount(product.discountPercentage)
        discountLabel.font = DesignSystem.number(34)
        discountLabel.textColor = DesignSystem.ink
        discountLabel.backgroundColor = DesignSystem.yellow
        discountLabel.textAlignment = .center
        discountLabel.layer.cornerRadius = 10
        discountLabel.layer.masksToBounds = true
        discountLabel.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(discountLabel)

        NSLayoutConstraint.activate([
            imageContainer.heightAnchor.constraint(equalToConstant: 320),

            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),

            discountLabel.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 20),
            discountLabel.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 20),
            discountLabel.widthAnchor.constraint(equalToConstant: 116),
            discountLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        stackView.addArrangedSubview(imageContainer)
        stackView.setCustomSpacing(24, after: imageContainer)
    }

    private func setupCategory() {
        let categoryLabel = UILabel()
        categoryLabel.text = product.category.capitalized
        categoryLabel.font = DesignSystem.text(12, weight: .semibold)
        categoryLabel.textColor = DesignSystem.blue

        let categoryView = UIView()
        categoryView.backgroundColor = DesignSystem.blueSoft
        categoryView.layer.cornerRadius = 9
        categoryView.addSubview(categoryLabel)

        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: categoryView.topAnchor, constant: 6),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryView.bottomAnchor, constant: -6),
            categoryLabel.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor, constant: 10),
            categoryLabel.trailingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: -10)
        ])

        let row = UIStackView(arrangedSubviews: [categoryView, UIView()])
        row.axis = .horizontal
        stackView.addArrangedSubview(row)
    }

    private func setupInfo() {
        titleLabel.text = product.title
        titleLabel.font = DesignSystem.serif(28, weight: .semibold)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(6, after: titleLabel)

        oldPriceLabel.attributedText = NSAttributedString(
            string: DesignSystem.price(DesignSystem.originalPrice(of: product)),
            attributes: [
                .font: DesignSystem.text(14),
                .foregroundColor: DesignSystem.gray,
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        stackView.addArrangedSubview(oldPriceLabel)
        stackView.setCustomSpacing(2, after: oldPriceLabel)

        priceLabel.text = DesignSystem.price(product.price)
        priceLabel.font = DesignSystem.number(46)
        priceLabel.textColor = DesignSystem.blue
        stackView.addArrangedSubview(priceLabel)
        stackView.setCustomSpacing(6, after: priceLabel)

        let savingsLabel = UILabel()
        savingsLabel.text = "Você economiza \(savingsText)"
        savingsLabel.font = DesignSystem.text(13, weight: .semibold)
        savingsLabel.textColor = DesignSystem.blue
        stackView.addArrangedSubview(savingsLabel)
        stackView.setCustomSpacing(26, after: savingsLabel)

        let aboutTitle = UILabel()
        aboutTitle.text = "Sobre o produto"
        aboutTitle.font = DesignSystem.text(15, weight: .semibold)
        aboutTitle.textColor = DesignSystem.ink
        stackView.addArrangedSubview(aboutTitle)

        let descriptionLabel = UILabel()
        descriptionLabel.text = product.description
        descriptionLabel.font = DesignSystem.serif(16.5)
        descriptionLabel.textColor = DesignSystem.ink
        descriptionLabel.numberOfLines = 0
        stackView.addArrangedSubview(descriptionLabel)
    }

    private func setupAddButton() {
        addButton.backgroundColor = DesignSystem.blue
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = DesignSystem.text(16, weight: .semibold)
        addButton.layer.cornerRadius = 18
        addButton.addTarget(self, action: #selector(toggleBag), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystem.margin),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystem.margin),
            addButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -10
            ),
            addButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    // MARK: - Dados

    private var savingsText: String {
        let original = DesignSystem.originalPrice(of: product)
        return DesignSystem.price(original - product.price)
    }

    private func configure() {
        ImageLoader.loadImage(from: product.images?.first ?? product.thumbnail) { [weak self] image in
            self?.imageView.image = image
        }
        updateButton()
    }

    @objc private func toggleBag() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        if WishlistService.shared.contains(product) {
            WishlistService.shared.remove(product)
        } else {
            WishlistService.shared.add(product)
        }
        updateButton()
    }

    @objc private func wishlistDidChange() {
        updateButton()
    }

    private func updateButton() {
        let inBag = WishlistService.shared.contains(product)

        addButton.setTitle(inBag ? "Na sacola" : "Adicionar à sacola", for: .normal)
        addButton.backgroundColor = inBag ? DesignSystem.blueSoft : DesignSystem.blue
        addButton.setTitleColor(inBag ? DesignSystem.blue : .white, for: .normal)
    }
}

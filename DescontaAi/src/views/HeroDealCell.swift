//
//  HeroDealCell.swift
//  DescontaAi
//

import UIKit

final class HeroDealCell: UITableViewCell {

    static let identifier = "HeroDealCell"

    private let panel = UIView()
    private let productImageView = UIImageView()
    private let discountLabel = UILabel()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()
    private let textStack = UIStackView()
    private let infoRow = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        panel.backgroundColor = DesignSystem.white
        panel.layer.cornerRadius = 20
        panel.layer.borderWidth = 1
        panel.layer.borderColor = DesignSystem.line.cgColor

        productImageView.backgroundColor = DesignSystem.white
        productImageView.contentMode = .scaleAspectFit
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 14

        discountLabel.textAlignment = .center
        discountLabel.font = DesignSystem.text(17, weight: .bold)
        discountLabel.textColor = DesignSystem.ink
        discountLabel.backgroundColor = DesignSystem.yellow
        discountLabel.layer.cornerRadius = 6
        discountLabel.layer.masksToBounds = true

        titleLabel.font = DesignSystem.text(18, weight: .semibold)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.numberOfLines = 2

        priceLabel.font = DesignSystem.text(22, weight: .bold)
        priceLabel.textColor = DesignSystem.blue

        oldPriceLabel.font = DesignSystem.text(12.5)
        oldPriceLabel.textColor = DesignSystem.gray

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Maior desconto da lista"
        subtitleLabel.font = DesignSystem.text(12.5, weight: .medium)
        subtitleLabel.textColor = DesignSystem.gray

        let priceRow = UIStackView(arrangedSubviews: [priceLabel, oldPriceLabel, UIView()])
        priceRow.axis = .horizontal
        priceRow.alignment = .firstBaseline
        priceRow.spacing = 8

        textStack.addArrangedSubview(subtitleLabel)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(priceRow)
        textStack.axis = .vertical
        textStack.spacing = 6

        // Desconto fica do lado direito das informações
        infoRow.addArrangedSubview(textStack)
        infoRow.addArrangedSubview(discountLabel)
        infoRow.axis = .horizontal
        infoRow.alignment = .center
        infoRow.spacing = 12

        [panel, productImageView, infoRow].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(panel)
        panel.addSubview(productImageView)
        panel.addSubview(infoRow)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            panel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DesignSystem.margin),
            panel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.margin),
            panel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            productImageView.topAnchor.constraint(equalTo: panel.topAnchor, constant: 14),
            productImageView.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 14),
            productImageView.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -14),
            productImageView.heightAnchor.constraint(equalToConstant: 196),

            discountLabel.widthAnchor.constraint(equalToConstant: 64),
            discountLabel.heightAnchor.constraint(equalToConstant: 30),

            infoRow.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 16),
            infoRow.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 18),
            infoRow.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -18),
            infoRow.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -20)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
    }

    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = DesignSystem.price(product.price)
        discountLabel.text = DesignSystem.discount(product.discountPercentage)

        oldPriceLabel.attributedText = NSAttributedString(
            string: DesignSystem.price(DesignSystem.originalPrice(of: product)),
            attributes: [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: DesignSystem.gray
            ]
        )

        let imageURL = product.images?.first ?? product.thumbnail
        ImageLoader.loadImage(from: imageURL) { [weak self] image in
            self?.productImageView.image = image
        }
    }
}

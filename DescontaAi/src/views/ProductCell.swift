//
//  ProductCell.swift
//  DescontaAi
//
//  Created by Yuri Elias on 16/11/26.
//
import UIKit

final class ProductCell: UITableViewCell {

    static let identifier = "ProductCell"

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()
    private let discountLabel = UILabel()

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
        thumbnailImageView.backgroundColor = DesignSystem.white
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.borderColor = DesignSystem.line.cgColor

        titleLabel.font = DesignSystem.text(15, weight: .medium)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.numberOfLines = 2

        priceLabel.font = DesignSystem.text(18, weight: .bold)
        priceLabel.textColor = DesignSystem.blue

        oldPriceLabel.font = DesignSystem.text(12.5)
        oldPriceLabel.textColor = DesignSystem.gray

        discountLabel.font = DesignSystem.text(17, weight: .bold)
        discountLabel.textColor = DesignSystem.ink
        discountLabel.textAlignment = .right

        let views = [thumbnailImageView, titleLabel, priceLabel, oldPriceLabel, discountLabel]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: DesignSystem.margin
            ),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 64),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 64),

            discountLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -DesignSystem.margin
            ),
            discountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            discountLabel.widthAnchor.constraint(equalToConstant: 58),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: discountLabel.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            oldPriceLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 7),
            oldPriceLabel.lastBaselineAnchor.constraint(equalTo: priceLabel.lastBaselineAnchor),
            oldPriceLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: discountLabel.leadingAnchor,
                constant: -8
            )
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
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

        ImageLoader.loadImage(from: product.thumbnail) { [weak self] image in
            self?.thumbnailImageView.image = image
        }
    }
}

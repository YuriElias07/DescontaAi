//
//  WishlistCell.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import UIKit

final class WishlistCell: UITableViewCell {

    static let identifier = "WishlistCell"

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let discountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        selectionStyle = .none

        thumbnailImageView.backgroundColor = DesignSystem.white
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 18
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.borderColor = DesignSystem.line.cgColor

        titleLabel.font = DesignSystem.serif(16, weight: .medium)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.numberOfLines = 2

        priceLabel.font = DesignSystem.number(18)
        priceLabel.textColor = DesignSystem.blue

        discountLabel.font = DesignSystem.text(12.5)
        discountLabel.textColor = DesignSystem.gray

        let views = [thumbnailImageView, titleLabel, priceLabel, discountLabel]
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
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DesignSystem.margin),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            discountLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 7),
            discountLabel.lastBaselineAnchor.constraint(equalTo: priceLabel.lastBaselineAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }

    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = DesignSystem.price(product.price)
        discountLabel.text = DesignSystem.discount(product.discountPercentage)

        ImageLoader.loadImage(from: product.thumbnail) { [weak self] image in
            self?.thumbnailImageView.image = image
        }
    }
}

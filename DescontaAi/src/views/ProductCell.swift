//
//  ProductCell.swift
//  DescontaAi
//
//  Created by Yuri Elias on 16/11/26.
//
import UIKit

class ProductCell: UITableViewCell {
    let thumbnailImageView = UIImageView()
    let titleLabel = UILabel()
    let priceLabel = UILabel()
    let discountLabel = UILabel()
    
    private var currentImageURL: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(discountLabel)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        discountLabel.translatesAutoresizingMaskIntoConstraints = false

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.backgroundColor = .systemGray6

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = .gray

        discountLabel.font = .systemFont(ofSize: 12, weight: .bold)
        discountLabel.textColor = .white
        discountLabel.backgroundColor = .systemRed
        discountLabel.layer.cornerRadius = 4
        discountLabel.clipsToBounds = true
        discountLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            thumbnailImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 60),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(
                equalTo: thumbnailImageView.trailingAnchor,
                constant: 12
            ),
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),

            priceLabel.leadingAnchor.constraint(
                equalTo: thumbnailImageView.trailingAnchor,
                constant: 12
            ),
            priceLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 4
            ),

            discountLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            discountLabel.centerYAnchor.constraint(
                equalTo: priceLabel.centerYAnchor
            ),
            discountLabel.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 50
            ),
            discountLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        currentImageURL = nil
    }
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "R$ \(String(format: "%.2f", product.price))"
        discountLabel.text = "-\(Int(product.discountPercentage))%"
        discountLabel.backgroundColor = product.discountPercentage >= 15 ? .systemRed : .systemOrange
        
        currentImageURL = product.thumbnail
        
        ImageLoader.loadImage(from: product.thumbnail) { [weak self] image in
            guard self?.currentImageURL == product.thumbnail else { return }
            self?.thumbnailImageView.image = image
        }
    }
}

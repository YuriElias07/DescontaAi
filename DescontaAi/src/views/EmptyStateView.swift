//
//  EmptyStateView.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import UIKit

final class EmptyStateView: UIView {

    init(icon: String, title: String, message: String) {
        super.init(frame: .zero)

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(
            systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        )
        iconImageView.tintColor = DesignSystem.gray
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystem.serif(22, weight: .semibold)
        titleLabel.textColor = DesignSystem.ink
        titleLabel.textAlignment = .center

        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = DesignSystem.text(15)
        messageLabel.textColor = DesignSystem.gray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),

            iconImageView.widthAnchor.constraint(equalToConstant: 72),
            iconImageView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

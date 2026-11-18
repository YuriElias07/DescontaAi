//
//  DesignSystem.swift
//  DescontaAi
//
//  Cores, fontes e medidas usadas no app.
//  A ideia é simples: fundo claro, azul para dinheiro e amarelo para desconto.
//

import UIKit

enum DesignSystem {

    // MARK: Cores

    static let background = UIColor(hex: 0xF6F7FB)
    static let white = UIColor.white
    static let ink = UIColor(hex: 0x15171E)
    static let gray = UIColor(hex: 0x6B7080)
    static let blue = UIColor(hex: 0x2334E5)
    static let blueSoft = UIColor(hex: 0xE5E8FF)
    static let yellow = UIColor(hex: 0xFFD234)
    static let line = UIColor(hex: 0xE4E6EF)

    /// Margem lateral padrão das telas.
    static let margin: CGFloat = 20

    // MARK: Fonte

    /// Todas as fontes do app usam a fonte do sistema.
    static func text(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }

    // MARK: Preço

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()

    static func price(_ value: Double) -> String {
        priceFormatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    static func discount(_ value: Double) -> String {
        "-\(Int(value.rounded()))%"
    }

    /// Preço "de" antes do desconto, para mostrar o valor riscado.
    static func originalPrice(of product: Product) -> Double {
        guard product.discountPercentage > 0 else { return product.price }
        return product.price / (1 - product.discountPercentage / 100)
    }
}

extension UIColor {
    convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

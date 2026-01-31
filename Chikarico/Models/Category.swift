import Foundation
import SwiftUI
import UIKit

struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: CategoryColor
    var isSystem: Bool
    var isHidden: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        color: CategoryColor,
        isSystem: Bool = false,
        isHidden: Bool = false
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.isSystem = isSystem
        self.isHidden = isHidden
    }
}

struct CategoryColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension Category {
    static let systemCategories: [Category] = [
        Category(name: "Services", color: CategoryColor(.blue), isSystem: true),
        Category(name: "Memberships", color: CategoryColor(.purple), isSystem: true),
        Category(name: "Bills", color: CategoryColor(.orange), isSystem: true),
        Category(name: "Education", color: CategoryColor(.green), isSystem: true),
        Category(name: "Personal", color: CategoryColor(.pink), isSystem: true),
        Category(name: "Other", color: CategoryColor(.gray), isSystem: true)
    ]
}

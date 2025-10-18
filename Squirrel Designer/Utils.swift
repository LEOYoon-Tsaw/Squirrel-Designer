//
//  Utils.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/25/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI

extension Binding {
    func unwrap<Wrapped: Sendable>(default defaultValue: Wrapped) -> Binding<Wrapped> where Value == Wrapped? {
        Binding<Wrapped>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

@MainActor
protocol Bindable {
    func binding<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>) -> Binding<T>
}

extension Bindable {
    func binding<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>) -> Binding<T> {
        return Binding(get: { self[keyPath: keyPath] }, set: { self[keyPath: keyPath] = $0 })
    }
}

struct DeletableRow<T, Content: View>: View {
    @Binding var optional: T?
    @ViewBuilder var content: Content
    @State private var hovering: Bool = false

    var body: some View {
        if optional != nil {
            HStack {
                content
                deleteButton
                    .opacity(hovering ? 1 : 0)
            }
            .onHover { hover in
                hovering = hover
            }
            .animation(.easeInOut(duration: 0.1), value: hovering)
        }
    }

    var deleteButton: some View {
        Button("DELETE_ROW", systemImage: "minus.circle") {
            optional = nil
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }
}

struct StaticRow<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack {
            content
            Label("DELETE_ROW", systemImage: "minus.circle")
                .labelStyle(.iconOnly)
                .hidden()
        }
    }
}

struct AddableTitle<Content: View>: View {
    let title: LocalizedStringResource
    let show: Bool
    @ViewBuilder var menu: Content
    @State private var hovering: Bool = false

    var body: some View {
        HStack {
            Text(title)
            menu
                .labelStyle(.iconOnly)
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .opacity(hovering && show ? 1 : 0.01)
        }
        .onHover { hover in
            hovering = hover
        }
        .animation(.easeInOut(duration: 0.1), value: hovering)
    }
}

struct NemericalCell: View {

    let text: LocalizedStringKey
    @Binding var value: Double
    let validation: ((Double) -> Double)?
    @State var tempValue: Double
    @FocusState var isFocused: Bool

    init(_ text: LocalizedStringKey, value: Binding<Double>, validation: ((Double) -> Double)? = nil) {
        self.text = text
        self._value = value
        self.validation = validation
        self._tempValue = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        TextField(text, value: $tempValue, format: .number.precision(.fractionLength(0...2)))
            .textFieldStyle(.roundedBorder)
            .focused($isFocused)
            .autocorrectionDisabled()
            .onSubmit(of: .text) {
                commit()
            }
            .onChange(of: isFocused) {
                if !isFocused {
                    commit()
                }
            }
            .onChange(of: value, initial: true) {
                tempValue = value
            }
    }

    func commit() {
        if let validation {
            tempValue = validation(tempValue)
        }
        value = tempValue
    }
}

struct SliderCell: View {
    @Binding var value: Double
    @State var currentValue: Double = 0
    let range: ClosedRange<Double>
    let label: LocalizedStringKey

    init(_ label: LocalizedStringKey, value: Binding<Double>, in range: ClosedRange<Double>) {
        self.label = label
        self._value = value
        self.range = range
        self._currentValue = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        HStack {
            Slider(value: $currentValue, in: range, step: 0.01) {
                Text(label)
            } onEditingChanged: { editing in
                if !editing {
                    value = currentValue
                }
            }

            let formatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 0
                return formatter
            }()
            Text(formatter.string(from: NSNumber(value: currentValue)) ?? "")
                .frame(maxWidth: 40, alignment: .trailing)
        }
        .onChange(of: value, initial: true) {
            currentValue = value
        }
    }
}

func populateFontMembers(for fontFamily: String) -> [String] {
    var allMembers = [String]()
    let members = NSFontManager.shared.availableMembers(ofFontFamily: fontFamily)
    if let members {
        for member in members {
            if let fontType = member[1] as? String {
                allMembers.append(fontType)
            }
        }
    }
    return allMembers
}

func readFont(family: String, style: String, size: Double) -> NSFont? {
    if let font = NSFont(name: "\(family.filter { !$0.isWhitespace })-\(style.filter { !$0.isWhitespace })", size: size) {
        return font
    }
    if let members = NSFontManager.shared.availableMembers(ofFontFamily: family) {
        for i in 0..<members.count {
            if let memberName = members[i][1] as? String, memberName == style,
               let weight = members[i][2] as? Int,
               let traits = members[i][3] as? UInt {
                return NSFontManager.shared.font(withFamily: family, traits: NSFontTraitMask(rawValue: traits), weight: weight, size: size)
            }
        }
    }
    if let font = NSFont(name: family, size: size) {
        return font
    }
    return nil
}

func getFontFamilyAndMember(font: NSFont) -> (String?, String?) {
    let family = font.familyName
    guard let family else { return (nil, nil) }
    var member: String?
    let fontMembers = NSFontManager.shared.availableMembers(ofFontFamily: family)
    for fontMember in fontMembers ?? [] {
        if let fontName = fontMember[0] as? String,
           let memberName = fontMember[1] as? String,
           font.fontName == fontName {
            member = memberName
        }
    }
    return (family, member)
}

extension NSRange {
  static let empty = NSRange(location: NSNotFound, length: 0)
}

extension NSPoint {
  static func += (lhs: inout Self, rhs: Self) {
    lhs.x += rhs.x
    lhs.y += rhs.y
  }
  static func - (lhs: Self, rhs: Self) -> Self {
    Self.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
  static func -= (lhs: inout Self, rhs: Self) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
  }
  static func * (lhs: Self, rhs: CGFloat) -> Self {
    Self.init(x: lhs.x * rhs, y: lhs.y * rhs)
  }
  static func / (lhs: Self, rhs: CGFloat) -> Self {
    Self.init(x: lhs.x / rhs, y: lhs.y / rhs)
  }
  var length: CGFloat {
    sqrt(pow(self.x, 2) + pow(self.y, 2))
  }
}

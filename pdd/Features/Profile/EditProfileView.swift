//
//  EditProfileView.swift
//  pdd
//
//  Edit profile with validation + phone mask (spec §10).
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var session = Session.shared

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var category = "Категория B"
    @State private var showToast = false

    private let categories = ["Категория B", "Категория C, D", "Категория A"]

    private var phoneDigits: String { phone.filter(\.isNumber) }
    private var isValid: Bool { !firstName.trimmingCharacters(in: .whitespaces).isEmpty && (phoneDigits.isEmpty || phoneDigits.count >= 11) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                field("Имя", text: $firstName, required: true)
                field("Фамилия", text: $lastName)
                phoneField
                categoryField
                PrimaryButton(title: "Сохранить", showsChevron: false, enabled: isValid) { save() }
                    .padding(.top, 8)
            }
            .padding(AppLayout.profileMargin)
        }
        .background(.white)
        .navigationTitle("Редактировать профиль")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showToast {
                Text("Сохранено").font(.app(15, .medium)).foregroundStyle(.white)
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(AppColor.textBlack.opacity(0.9), in: Capsule())
                    .padding(.bottom, 30).transition(.opacity)
            }
        }
        .onAppear {
            let u = session.displayUser
            firstName = u.firstName; lastName = u.lastName; phone = u.phone
            category = u.licenseCategory.isEmpty ? "Категория B" : u.licenseCategory
        }
    }

    private func field(_ title: String, text: Binding<String>, required: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title + (required ? " *" : "")).font(.app(14, .medium)).foregroundStyle(AppColor.greyText)
            TextField("", text: text)
                .font(.app(16)).foregroundStyle(AppColor.textBlack)
                .padding(.horizontal, 16).frame(height: 52)
                .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Телефон").font(.app(14, .medium)).foregroundStyle(AppColor.greyText)
            TextField("+7 (___) ___-__-__", text: $phone)
                .keyboardType(.phonePad)
                .font(.app(16)).foregroundStyle(AppColor.textBlack)
                .padding(.horizontal, 16).frame(height: 52)
                .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 14))
                .onChange(of: phone) { _, new in phone = Self.maskPhone(new) }
        }
    }

    private var categoryField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Категория прав").font(.app(14, .medium)).foregroundStyle(AppColor.greyText)
            Menu {
                ForEach(categories, id: \.self) { c in Button(c) { category = c } }
            } label: {
                HStack {
                    Text(category).font(.app(16)).foregroundStyle(AppColor.textBlack)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundStyle(AppColor.greyText)
                }
                .padding(.horizontal, 16).frame(height: 52)
                .background(AppColor.lightBg, in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func save() {
        var u = session.displayUser
        u.firstName = firstName; u.lastName = lastName; u.phone = phone; u.licenseCategory = category
        session.update(user: u)
        withAnimation { showToast = true }
        Haptics.notify(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { showToast = false } }
    }

    /// Formats digits into +7 (XXX) XXX-XX-XX.
    static func maskPhone(_ input: String) -> String {
        var digits = input.filter(\.isNumber)
        if digits.first == "8" { digits.removeFirst(); digits = "7" + digits }
        if digits.first != "7" { digits = "7" + digits }
        digits = String(digits.prefix(11))
        var out = "+7"
        let rest = Array(digits.dropFirst())
        if !rest.isEmpty { out += " (" + String(rest.prefix(3)) }
        if rest.count >= 3 { out += ")" }
        if rest.count > 3 { out += " " + String(rest[3..<min(6, rest.count)]) }
        if rest.count > 6 { out += "-" + String(rest[6..<min(8, rest.count)]) }
        if rest.count > 8 { out += "-" + String(rest[8..<min(10, rest.count)]) }
        return out
    }
}

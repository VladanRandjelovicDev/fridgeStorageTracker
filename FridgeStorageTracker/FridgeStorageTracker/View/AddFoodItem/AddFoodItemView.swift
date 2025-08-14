import SwiftUI

struct AddFoodItemView: View {

    @Environment(\.dismiss) private var dismiss

    let viewModel: AddFoodItemViewModel

    @State private var name = ""
    @State private var category: FoodItemCategory = .fruit
    @State private var bestBefore = Date()
    @State private var dateStored = Date()

    var body: some View {
        Form {
            TextField("Name", text: $name)

            Picker("Category", selection: $category) {
                ForEach(FoodItemCategory.allCases, id: \.rawValue) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }

            DatePicker("Best Before", selection: $bestBefore, displayedComponents: .date)
            DatePicker("Date Stored", selection: $dateStored, displayedComponents: .date)

            Section {
                Button("Save") {
                    save()
                }
                .disabled(name.isEmpty)
            }
        }
        .navigationTitle("Add Item")
    }

    private func save() {
        Task { @MainActor in
            await viewModel.addItem(name: name, category: category, dateStored: dateStored, expiryDate: bestBefore)
            dismiss()
        }
    }
}

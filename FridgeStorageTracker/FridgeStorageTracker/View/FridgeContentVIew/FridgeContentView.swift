import SwiftUI
import Combine

struct FridgeContentView: View {

    let viewModel: FridgeContentViewModel
    @State var viewState: FridgeContentViewState = .loading()
    @State private var showSortOptions = false
    @State private var showAddItem = false
    @State var bindingCancelable: AnyCancellable?

    var body: some View {
        NavigationView {
            fridgeContent
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Your Fridge")
                }

                ToolbarItem {
                    Button(action: { showSortOptions = true }) {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                    .confirmationDialog("Sort by", isPresented: $showSortOptions) {
                        Button("Name") { sort(by: .name) }
                        Button("Date Stored") { sort(by: .dateStored) }
                        Button("Expiry Date") { sort(by: .expiryDate) }
                        Button("Cancel", role: .cancel) {}
                    }
                }

                ToolbarItem {
                    Button(action: { showAddItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }

        }.onAppear {
            bindToViewModel()
        }.onDisappear {
            bindingCancelable?.cancel()
            viewModel.invalidate()
        }
        .sheet(isPresented: $showAddItem) {
            NavigationView {
                AddFoodItemView(viewModel: AddFoodItemViewModelImpl())
            }
        }
    }

    @ViewBuilder
    var fridgeContent: some View {
        if viewState.isLoading {
            loadingProgress
        } else {
            fridgeItems
        }
    }

    @ViewBuilder
    var loadingProgress: some View {
        ProgressView()
    }

    @ViewBuilder
    var fridgeItems: some View {
        List {
            ForEach(viewState.foodItems, id: \.self) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.title)
                    Text("Added on \(item.storedDate), expires in: \(item.expiresInDays)")
                        .font(.caption)
                }
            }
            .onDelete(perform: deleteItem)
        }
    }

    private func sort(by option: FridgeContentViewState.SortByType) {
        viewModel.sortBy(option)
    }

    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            let idsToDelete = viewState.foodItems
                .enumerated()
                .filter { index, _ in offsets.contains(index) }
                .map { _, item in item.id }

            viewModel.deleteItems(ids: idsToDelete)
        }
    }

    private func bindToViewModel() {
        bindingCancelable = viewModel.viewState
            .sink(receiveValue: {
                self.viewState = $0
            })
    }
}

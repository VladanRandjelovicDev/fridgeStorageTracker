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
                    Text(expiryInfoText(for: item))
                        .font(.caption)
                }
				 .padding()
				 .background(backgroundColor(for: item))
				 .cornerRadius(8)
				 .opacity(opacityForItem(item))
            }
            .onDelete(perform: deleteItem)
        }
    }
	
	private func expiryInfoText(for item: FoodItemViewData) -> String {
		if let daysLeft = Int(item.expiresInDays) {
			if daysLeft < 0 {
				return "Added on \(item.storedDate), expired"
			} else if daysLeft == 0 {
				return "Added on \(item.storedDate), expires today"
			} else {
				return "Added on \(item.storedDate), expires in: \(daysLeft) days"
			}
		}
		return "Added on \(item.storedDate), no expiry info"
	}
	
	private func backgroundColor(for item: FoodItemViewData) -> Color {
		if let daysLeft = Int(item.expiresInDays) {
			if daysLeft < 0 {
				return Color.red.opacity(0.2)    // expired
			} else if daysLeft <= 3 {
				return Color.yellow.opacity(0.2) // near expiry
			}
		}
		return Color.clear
	}

	private func opacityForItem(_ item: FoodItemViewData) -> Double {
		if let daysLeft = Int(item.expiresInDays), daysLeft < 0 {
			return 0.6 // faded for expired
		}
		return 1.0
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

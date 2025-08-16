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
				HStack(alignment: .top, spacing: 12) {
                    if item.category == .meat {
                        Image("meat")
                            .font(.title2)
                    } else {
                        Image(systemName: iconName(for: item))
                            .font(.title2)
                    }
					VStack(alignment: .leading) {
						Text(item.title)
							.font(.title)
						Text(expiryInfoText(for: item))
							.font(.caption)
					}
				}
					 .padding()
					 .background(backgroundColor(for: item))
					 .cornerRadius(8)
					 .opacity(opacityForItem(item))
			}
			.onDelete(perform: deleteItem)
        }
    }
	
	private func iconName(for item: FridgeContentViewState.FoodItemViewState) -> String {
		switch item.category {
        case .meat:
			return "steak" // iOS 17+, shows a piece of meat
        case .fruit:
			return "apple.logo" // classic apple icon
        case .dairy:
			return "cup.and.saucer.fill" // cup of milk/tea
        case .vegetable:
			return "carrot" // or "leaf.fill" if carrot isn't available
        case .grain:
			return "bag.fill" // resembles a sack of grain/flour
		default:
			return "fork.knife" // fallback for unknown categories
		}
	}

	
	private func expiryInfoText(for item: FridgeContentViewState.FoodItemViewState) -> String {
		
        if let daysLeft = item.expiresInDays {
            let expiresInDays = Int(daysLeft)
                if expiresInDays < 0 {
                    return "Added on \(item.storedDate), expired"
                } else if expiresInDays == 0 {
                    return "Added on \(item.storedDate), expires today"
                } else {
                    return "Added on \(item.storedDate), expires in: \(expiresInDays) days"
                }

        }
		return "Added on \(item.storedDate), no expiry info"
	}
	
	private func backgroundColor(for item: FridgeContentViewState.FoodItemViewState) -> Color {
        if let daysLeft = item.expiresInDays {
            let expiresInDays = Int(daysLeft)
			if expiresInDays < 0 {
				return Color.red.opacity(0.2)    // expired
			} else if expiresInDays <= 3 {
				return Color.yellow.opacity(0.2) // near expiry
			}
		}
		return Color.clear
	}

	private func opacityForItem(_ item: FridgeContentViewState.FoodItemViewState) -> Double {
        
        if let daysLeft = item.expiresInDays {
            let expiresInDays = Int(daysLeft)
            if daysLeft < 0 {
                return 0.6 // faded for expired
            }
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

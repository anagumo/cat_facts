import SwiftUI

struct FactsView: View {
    @State var factsViewModel: FactsViewModel
    
    init(factsViewModel: FactsViewModel = FactsViewModel()) {
        self.factsViewModel = factsViewModel
    }
    
    var body: some View {
        NavigationStack {
            switch factsViewModel.factsState {
            case .none:
                Text("Nothing to show")
            case .loading:
                Text("Loading...")
            case .loaded:
                List(factsViewModel.facts, id: \.id) { item in
                    Text(item.text)
                }
                .navigationTitle("🐱 Cat Facts")
            }
        }
        .onAppear(perform: {
            factsViewModel.load()
        })
    }
}

#Preview {
    FactsView()
}

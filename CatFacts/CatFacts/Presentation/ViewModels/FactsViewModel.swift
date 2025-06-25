import Foundation

enum FactsState {
    case loading, loaded, error
}

@Observable
final class FactsViewModel {
    
    @ObservationIgnored
    private let getFactsUseCase: GetFactsUseCaseProtocol
    var factsState: FactsState
    var facts: [FactModel]
    
    init(getFactsUseCase: GetFactsUseCaseProtocol = GetFactsUseCase()) {
        self.getFactsUseCase = getFactsUseCase
        factsState = .loading
        facts = []
    }
    
    func load() {
        Task { @MainActor in
            do {
                let facts = try await getFactsUseCase.run()
                self.facts = facts
                factsState = .loaded
            } catch {
                debugPrint(error.localizedDescription)
                factsState = .error
            }
        }
    }
}

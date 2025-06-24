import Foundation

protocol GetFactsUseCaseProtocol {
    func run() async throws -> [FactModel]
}

final class GetFactsUseCase: GetFactsUseCaseProtocol {
    private let factsRepository: FactsRepositoryProtocol
    
    init(factsRepository: FactsRepositoryProtocol = FactsRepository()) {
        self.factsRepository = factsRepository
    }
    
    func run() async throws -> [FactModel] {
        try await factsRepository.getAll()
    }
}

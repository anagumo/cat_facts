import Foundation

protocol FactsRepositoryProtocol {
    func getAll() async throws -> [FactModel]
}

final class FactsRepository: FactsRepositoryProtocol {
    private let apiSession: APISessionContract
    
    init(apiSession: APISessionContract = APISession.shared) {
        self.apiSession = apiSession
    }
    
    func getAll() async throws -> [FactModel] {
        let factDTOList = try await apiSession.request(
            GetFactsURLRequest()
        ).data
        
        return factDTOList.map {
            FactDTOToDomainMapper().map($0)
        }
    }
}

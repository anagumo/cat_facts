import Foundation

struct FactDTOToDomainMapper {
    func map(_ dto: FactDTO) -> FactModel {
        FactModel(text: dto.fact)
    }
}

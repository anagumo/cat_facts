import Foundation

struct GetFactsURLRequest: URLRequestComponents {
    var path: String = "/facts"
    var queryParameters: [String : String]?
    var httpMethod: HTTPMethod = .GET
    typealias Response = CatFactResponse
    
    init() {
        queryParameters = [
            "max_length": "60",
            "limit": "20"
        ]
    }
}

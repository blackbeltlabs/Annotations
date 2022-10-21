import Foundation

public final class JSONSerializer {
  static public func deserializeFromFile(url: URL) throws -> SortedDataDeserializationResult {
    let data = try Data(contentsOf: url)
    return try deserializeFromSortedData(data: data)
  }
  
  static public func deserializeFromSortedData(data: Data) throws -> SortedDataDeserializationResult {
    let decoder = JSONDecoder()
    
    let jsonSortedObject = try decoder.decode(JSONSortedModel.self, from: data)
    
    return JSONModelsConverter.convertSortedModel(jsonSortedObject)
  }
  
  
  static public func deserializeFromFile(url: URL,
                                         completion: @escaping (Result<SortedDataDeserializationResult, Error>) -> Void) {
    DispatchQueue.global().async {
      do {
        let data = try deserializeFromFile(url: url)
        DispatchQueue.main.async {
          completion(.success(data))
        }
        
      } catch let error {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }
}

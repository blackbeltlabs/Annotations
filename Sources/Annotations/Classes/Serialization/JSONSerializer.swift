import Foundation

public final class JSONSerializer {
  
  // MARK: - Serialize
  
  static public func serializeToSortedData(_ models: [AnnotationModel]) throws -> Data {
    let sortedData = JSONModelsConverter.convertToSortedModel(models)
    
    let encoder = JSONEncoder()
  
    return try encoder.encode(sortedData)
  }
  
  // MARK: - Deserialize
  static public func deserializeFromFile(url: URL) throws -> SortedDataDeserializationResult {
    let data = try Data(contentsOf: url)
    return try deserializeFromSortedData(data: data)
  }
  
  static public func deserializeFromSortedData(data: Data) throws -> SortedDataDeserializationResult {
    let decoder = JSONDecoder()
    
    let jsonSortedObject = try decoder.decode(JSONSortedModel.self, from: data)
    
    return JSONModelsConverter.convertFromSortedModel(jsonSortedObject)
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

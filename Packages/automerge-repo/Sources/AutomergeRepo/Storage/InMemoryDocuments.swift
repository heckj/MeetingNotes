import struct Foundation.Data

actor InMemoryDocuments: StorageProvider {
    var _storage: [DocumentId: Data] = [:]
    var _incrementalChunks: [CombinedKey: [Data]] = [:]

    struct CombinedKey: Hashable {
        let id: DocumentId
        let prefix: String
    }

    func load(key: DocumentId) async -> Data? {
        _storage[key]
    }

    func save(key: DocumentId, data: Data) async {
        _storage[key] = data
    }

    func remove(key: DocumentId) async {
        _storage.removeValue(forKey: key)
    }

    // MARK: Incremental Load Support

    func addToRange(key: DocumentId, prefix: String, data: Data) async {
        var dataArray: [Data] = _incrementalChunks[CombinedKey(id: key, prefix: prefix)] ?? []
        dataArray.append(data)
        _incrementalChunks[CombinedKey(id: key, prefix: prefix)] = dataArray
    }

    func loadRange(key: DocumentId, prefix: String) async -> [Data] {
        _incrementalChunks[CombinedKey(id: key, prefix: prefix)] ?? []
    }

    func removeRange(key: DocumentId, prefix: String) async {
        _incrementalChunks.removeValue(forKey: CombinedKey(id: key, prefix: prefix))
    }
}

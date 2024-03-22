import Automerge
@testable import AutomergeRepo
import AutomergeUtilities
import XCTest

final class RepoTests: XCTestCase {
    let network = InMemoryNetwork.shared
    var repo: Repo!

    override func setUp() async throws {
        repo = Repo(sharePolicy: SharePolicies.agreeable)
    }

    func testMostBasicRepoStartingPoints() async throws {
        // Repo
        //  property: peers [PeerId] - all (currently) connected peers
        let peers = await repo.peers()
        XCTAssertEqual(peers, [])

        // let peerId = await repo.peerId
        // print(peerId)

        // - func storageId() -> StorageId (async)
        let storageId = await repo.storageId()
        XCTAssertNil(storageId)

        let knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds, [])
    }

    func testCreate() async throws {
        let newDoc = try await repo.create()
        XCTAssertNotNil(newDoc)
        let knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 1)
    }

    func testCreateWithId() async throws {
        let myId = DocumentId()
        let (id, _) = try await repo.create(id: myId)
        XCTAssertEqual(myId, id)

        let knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 1)
        XCTAssertEqual(knownIds[0], myId)
    }

    func testCreateWithExistingDoc() async throws {
        let (id, _) = try await repo.create(doc: Document())
        var knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 1)
        XCTAssertEqual(knownIds[0], id)

        let myId = DocumentId()
        let _ = try await repo.create(doc: Document(), id: myId)
        knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 2)
    }

    func testFind() async throws {
        let myId = DocumentId()
        let (id, newDoc) = try await repo.create(id: myId)
        XCTAssertEqual(myId, id)

        let foundDoc = try await repo.find(id: myId)
        XCTAssertEqual(foundDoc.actor, newDoc.actor)
    }

    func testFindFailed() async throws {
        do {
            let _ = try await repo.find(id: DocumentId())
            XCTFail()
        } catch {}
    }

    func testDelete() async throws {
        let myId = DocumentId()
        let _ = try await repo.create(id: myId)
        var knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 1)

        try await repo.delete(id: myId)
        knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 0)

        do {
            let _ = try await repo.find(id: DocumentId())
            XCTFail()
        } catch {}
    }

    func testClone() async throws {
        let myId = DocumentId()
        let (id, myCreatedDoc) = try await repo.create(id: myId)
        XCTAssertEqual(myId, id)

        let (newId, clonedDoc) = try await repo.clone(id: myId)
        XCTAssertNotEqual(newId, id)
        XCTAssertNotEqual(myCreatedDoc.actor, clonedDoc.actor)

        let knownIds = await repo.documentIds()
        XCTAssertEqual(knownIds.count, 2)
    }

    func testExportFailureUnknownId() async throws {
        do {
            _ = try await repo.export(id: DocumentId())
            XCTFail()
        } catch {}
    }

    func testExport() async throws {}

    func testImport() async throws {}

    // TBD:
    // - func storageIdForPeer(peerId) -> StorageId
    // - func subscribeToRemotes([StorageId])

    func testRepoSetup() async throws {
        let repoA = Repo(sharePolicy: SharePolicies.agreeable)
        let storage = await InMemoryStorage()
        await repoA.addStorageProvider(storage)

        let storageId = await repoA.storageId()
        XCTAssertNotNil(storageId)

//        let adapter = await network.createNetworkEndpoint(config: .init(localPeerId: "onePeer", localMetaData: nil,
//        listeningNetwork: false, name: "A"))
//        await repoA.addNetworkAdapter(adapter: adapter)
//
//        let peers = await repo.peers()
//        XCTAssertEqual(peers, [])
    }
}
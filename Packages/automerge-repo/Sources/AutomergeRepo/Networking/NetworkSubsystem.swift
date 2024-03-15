import AsyncAlgorithms
import Automerge
import struct Foundation.Data

// riff
// https://github.com/automerge/automerge-repo/blob/main/packages/automerge-repo/src/network/NetworkSubsystem.ts

/// A type that hosts network subsystems to connect to peers.
///
/// The NetworkSubsystem instance is responsible for setting up and configuring any network providers, and responding to
/// messages from remote peers after the connection has been established. The connection handshake and peer negotiation
/// is
/// the responsibility of the network provider instance.
public actor NetworkSubsystem: NetworkEventReceiver {
    public func receiveEvent(event _: NetworkAdapterEvents) async {}

    var adapters: [any NetworkProvider]
    let combinedNetworkEvents: AsyncChannel<NetworkAdapterEvents>
    var _backgroundNetworkReaderTasks: [Task<Void, Never>] = []

    init(adapters: [any NetworkProvider], peerId: PEER_ID, metadata: PeerMetadata?) async {
        self.adapters = adapters
        combinedNetworkEvents = AsyncChannel()
        for adapter in adapters {
            // tells the adapter to send network events to us
            adapter.setDelegate(something: self)
            await adapter.connect(asPeer: peerId, metadata: metadata)
        }
    }

    func remoteFetch(id _: DocumentId) async throws -> Document? {
        // attempt to fetch the provided document Id from all peers, returning the document
        // or returning nil if the document is unavailable.
        // Save the throwing scenarios for failures in connection, etc.

        try await allNetworksReady()
        fatalError("NOT IMPLEMENTED")
    }

    func send(message: SyncV1Msg) async {
        // send any message to ALL adapters (is this right?)
        for n in adapters {
            await n.send(message: message)
        }
    }

    // async waits until underlying networks are connected and ready to send and receive messages
    // (aka all networks are connected and "peered")
    func isReady() async -> Bool {
        for adapter in adapters {
            if await !adapter.ready() {
                return false
            }
        }
        return true
    }

    func allNetworksReady() async throws {
        var currentlyReady = await self.isReady()
        while currentlyReady != true {
            try await Task.sleep(for: .milliseconds(500))
            currentlyReady = await self.isReady()
        }
    }

    // combine version
    // import class Combine.PassthroughSubject
//    let eventPublisher: PassthroughSubject<NetworkAdapterEvents, Never> = PassthroughSubject()
}

// Collection point for all messages coming in, and going out, of the repository
// it forwards messages from network peers into the relevant places, and forwards messages
// out to peers as needed
//
// In automerge-repo code, it appears to update information on an ephemeral information (
// a sort of middleware) before emitting it upwards.
//
// Expected message types to forward:
//    isSyncMessage(message) ||
//    isEphemeralMessage(message) ||
//    isRequestMessage(message) ||
//    isDocumentUnavailableMessage(message) ||
//    isRemoteSubscriptionControlMessage(message) ||
//    isRemoteHeadsChanged(message)
//

// It also hosts peer to peer network components to allow for browsing and selection of connection,
// as well as potentially an "autoconnect" mode for P2P

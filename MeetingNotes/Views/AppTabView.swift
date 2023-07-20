import SwiftUI

struct AppTabView: View {
    @ObservedObject var document: MeetingNotesDocument
    // The undo manager triggers serializations and saving changes to the model
    // back into the automerge document (as a part of it's "save to disk"
    // sequence with ReferenceFileDocument.
    @Environment(\.undoManager) var undoManager
    @State private var selection: AgendaItem.ID?

    var body: some View {
        NavigationSplitView {
            VStack {
                TextField("Meeting Title", text: $document.model.title)
                    .onSubmit {
                        undoManager?.registerUndo(withTarget: document) { _ in }
                        // Registering an undo with even an empty handler for re-do marks
                        // the associated document as 'dirty' and causes SwiftUI to invoke
                        // a snapshot to save the file.
                    }
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                List($document.model.agendas, selection: $selection) { $agendaItem in
                    Label(agendaItem.title, systemImage: "note.text")
                }
                if let syncController = document.syncController {
                    PeerSyncView(syncController: syncController)
                }
            }
            .navigationSplitViewColumnWidth(min: 250, ideal: 250)
            .toolbar {
                ToolbarItem(id: "merge", placement: .principal) {
                    MergeView(document: document)
                }
                ToolbarItem(id: "sync", placement: .status) {
                    SyncView(document: document)
                }
            }
        } detail: {
            if selection != nil {
                EditableAgendaItemView(document: document, agendaItemId: selection)
                    // Using .id here is critical to getting views to update
                    // upon choosing a new selection on macOS
                    .id(selection)
            } else {
                Text("Select an agenda item")
            }
        }
        #if os(iOS)
        // hides the additional navigation stacks that iOS imposes on a document-based app
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            AppTabView(document: MeetingNotesDocument.sample())
        }
        #else
        AppTabView(document: MeetingNotesDocument.sample())
        #endif
    }
}

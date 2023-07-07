import Automerge
import SwiftUI

struct DocumentEditorView: View {
    // Document is needed within this file to link to the undo manager.
    @ObservedObject var document: MeetingNotesDocument
    // The undo manager triggers serializations and saving changes to the model
    // back into the automerge document (as a part of it's "save to disk"
    // sequence with ReferenceFileDocument.
    @Environment(\.undoManager) var undoManager

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Document ID: \(document.id)")
                    .font(.caption)
                Spacer()
            }
            List {
                Section {
                    TextField("Meeting Title", text: $document.model.title)
                        .onSubmit {
                            undoManager?.registerUndo(withTarget: document) { _ in }
                            // registering an undo with even an empty handler for re-do marks
                            // the associated document as 'dirty' and causes SwiftUI to invoke
                            // a snapshot to save the file.
                        }
                        .autocorrectionDisabled()
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                    #endif
                }
                Section("Attendees") {
                    if document.model.attendees.isEmpty {
                        Text("No attendeees listed")
                            .foregroundStyle(.gray)
                            .italic()
                    } else {
                        ForEach(document.model.attendees, id: \.self) { attendee in
                            Text(attendee)
                        }
                    }
                }
                Section {
                    ForEach($document.model.agendas, id: \.self) { agendaItem in
                        EditableAgendaItemListView(document: document, agendaItemBinding: agendaItem)
                    }
                } header: {
                    HStack {
                        Text("Agenda")
                        Button {
                            let newAgendaItem = AgendaItem(title: "")
                            print("Adding agenda item!")
                            document.model.agendas.append(newAgendaItem)
                            undoManager?.registerUndo(withTarget: document) { _ in }
                            // Registering an undo with even an empty handler for re-do marks
                            // the associated document as 'dirty' and causes SwiftUI to invoke
                            // a snapshot to save the file.
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                } footer: {
                    Text("footer here")
                }
            }
        }
    }
}

struct DocumentEditorView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentEditorView(document: MeetingNotesDocument.sample())
    }
}

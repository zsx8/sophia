//
//  ContentView.swift
//  sophia
//
//  Created by zs on 23.08.26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = ChatStore()

    @State private var renamingChatID: UUID?
    @State private var renameText: String = ""

    var body: some View {
        NavigationSplitView {
            List(selection: $store.selectedChatID) {
                ForEach(store.chats) { chat in
                    Text(chat.title)
                        .lineLimit(1)
                        .tag(chat.id)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.deleteChat(chat.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                startRenaming(chat)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .contextMenu {
                            Button {
                                startRenaming(chat)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                store.deleteChat(chat.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.newChat()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .alert(
                "Rename Chat",
                isPresented: Binding(
                    get: { renamingChatID != nil },
                    set: { if !$0 { renamingChatID = nil } }
                )
            ) {
                TextField("Chat name", text: $renameText)
                Button("Save") {
                    if let id = renamingChatID {
                        store.renameChat(id, to: renameText)
                    }
                    renamingChatID = nil
                }
                Button("Cancel", role: .cancel) {
                    renamingChatID = nil
                }
            }
        } detail: {
            if let binding = selectedChatBinding {
                ChatDetailView(chat: binding, store: store)
            } else {
                Text("Select or start a chat")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func startRenaming(_ chat: ChatSession) {
        renamingChatID = chat.id
        renameText = chat.title
    }

    private var selectedChatBinding: Binding<ChatSession>? {
        guard let id = store.selectedChatID,
              let index = store.chats.firstIndex(where: { $0.id == id }) else { return nil }
        return $store.chats[index]
    }
}

#Preview {
    ContentView()
}

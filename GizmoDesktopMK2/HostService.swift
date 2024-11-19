//
//  HostService.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//
import Foundation
import Network

class HostService {
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    
    // Add this property to hold MessageReceivers for each connection
    private var messageReceivers: [ObjectIdentifier: MessageReceiver] = [:]
    
    public var userData: UserData
    
    init() {
        userData = UserData.load()
        startListening()
    }
    
    func startListening() {
        do {
            let parameters = NWParameters.tcp
            listener = try NWListener(using: parameters)
            listener?.service = NWListener.Service(name: "GizmoHost", type: "_gizmo._tcp")
            
            listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("Listener ready on port \(String(describing: self.listener?.port))")
                case .failed(let error):
                    print("Listener failed with error: \(error)")
                    self.listener?.cancel()
                default:
                    break
                }
            }
            
            listener?.newConnectionHandler = { [weak self] newConnection in
                self?.accept(connection: newConnection)
            }
            
            listener?.start(queue: .main)
            print("Started listening...")
        } catch {
            print("Failed to create listener: \(error)")
        }
    }
    
    private func accept(connection: NWConnection) {
        connections.append(connection)
        
        // Store MessageReceiver with ObjectIdentifier(connection) as the key
        messageReceivers[ObjectIdentifier(connection)] = MessageReceiver()
        
        connection.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                print("Connection ready: \(connection.endpoint)")
                self?.receive(on: connection)
            case .failed(let error):
                print("Connection failed with error: \(error)")
                self?.removeConnection(connection)
            case .cancelled:
                print("Connection cancelled")
                self?.removeConnection(connection)
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    
    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            if let data = data, !data.isEmpty {
                if let receiver = self.messageReceivers[ObjectIdentifier(connection)] {
                    receiver.receive(data: data) { messageData in
                        self.handleReceivedData(messageData, on: connection)
                    }
                } else {
                    print("No MessageReceiver for connection: \(connection)")
                }
            }
            if let error = error {
                print("Receive error: \(error)")
                self.removeConnection(connection)
            } else if isComplete {
                print("Connection closed by remote peer")
                self.removeConnection(connection)
            } else {
                self.receive(on: connection)
            }
        }
    }

    
    private func handleReceivedData(_ data: Data, on connection: NWConnection) {
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(Message.self, from: data)
            switch message.type {
            case .listPages:
                handleListPagesRequest(on: connection)
            case .listShortcuts:
                handleListShortcutsRequest(on: connection)
            case .listActions:
                handleListActionsRequest(on: connection)
            case .executeAction:
                if let request = message.decodePayload(as: ExecuteActionRequest.self) {
                    handleExecuteAction(request, on: connection)
                }
            case .createAction:
                if let request = message.decodePayload(as: CreateActionRequest.self) {
                    handleCreateAction(request, on: connection)
                }
            case .createExecutor:
                if let request = message.decodePayload(as: CreateExecutorRequest.self) {
                    handleCreateExecutor(request, on: connection)
                }
            case .modifyAction:
                if let request = message.decodePayload(as: ModifyActionRequest.self) {
                    handleModifyAction(request, on: connection)
                }
            case .deleteAction:
                if let request = message.decodePayload(as: DeleteActionRequest.self) {
                    handleDeleteAction(request, on: connection)
                }
            case .deleteExecutor:
                if let request = message.decodePayload(as: DeleteExecutorRequest.self) {
                    handleDeleteExecutor(request, on: connection)
                }
            case .updateExecutor:
                if let request = message.decodePayload(as: UpdateExecutorRequest.self) {
                    handleModifyExecutor(request, on: connection)
                }
            case .swapExecutor:
                if let request = message.decodePayload(as: SwapExecutorRequest.self) {
                    handleSwapExecutor(request, on: connection)
                }
            default:
                sendError(message: "Unsupported message type", on: connection)
            }
        } catch {
            print("Failed to decode message: \(error)")
            print(data)
            sendError(message: "Invalid message format", on: connection)
        }
    }
    
    // Handle ListPagesRequest
    private func handleListPagesRequest(on connection: NWConnection) {
        let pagesList = PagesListResponse(pages: fetchPages())
        if let message = Message.encodeMessage(type: .pagesList, payload: pagesList) {
            send(message, on: connection)
        }
    }
    
    private func handleListShortcutsRequest(on connection: NWConnection) {
        let shortcuts = ShortcutsListResponse(shortcuts: fetchShortcuts())
        if let message = Message.encodeMessage(type: .shortcutsList, payload: shortcuts) {
            send(message, on: connection)
        }
    }
    
    private func handleListActionsRequest(on connection: NWConnection) {
        let actionsList = ActionsListResponse(actions: fetchActions())
        if let message = Message.encodeMessage(type: .actionsList, payload: actionsList) {
            send(message, on: connection)
        }
    }
    
    // Handle ExecuteActionRequest
    private func handleExecuteAction(_ request: ExecuteActionRequest, on connection: NWConnection) {
        // Execute the action based on actionID
        let success = executeAction(withID: request.actionID)
        let response = ActionExecutedResponse(actionID: request.actionID, success: success, message: success ? "Action executed successfully" : "Failed to execute action")
        if let message = Message.encodeMessage(type: .actionExecuted, payload: response) {
            send(message, on: connection)
        }
    }
    
    // Handle CreateActionRequest
    private func handleCreateAction(_ request: CreateActionRequest, on connection: NWConnection) {
        let success = createAction(action: request.action)
        let response = ActionUpdatedResponse(actionID: request.action.id, success: success, message: success ? "Action created successfully" : "Failed to create action")
        if let message = Message.encodeMessage(type: .actionUpdated, payload: response) {
            send(message, on: connection)
        }
    }
    
    private func handleCreateExecutor(_ request: CreateExecutorRequest, on connection: NWConnection) {
        let success = createExecutor(executor: request.executor, pageID: request.pageID)
        let response = ExecutorUpdatedResponse(executorID: request.executor.id, success: success, message: success ? "Executor created successfully" : "Failed to create executor")
        if let message = Message.encodeMessage(type: .executorUpdated, payload: response) {
            send(message, on: connection)
        }
    }
    
    // Handle ModifyActionRequest
    private func handleModifyAction(_ request: ModifyActionRequest, on connection: NWConnection) {
        let success = modifyAction(action: request.action)
        let response = ActionUpdatedResponse(actionID: request.action.id, success: success, message: success ? "Action modified successfully" : "Failed to modify action")
        if let message = Message.encodeMessage(type: .actionUpdated, payload: response) {
            send(message, on: connection)
        }
    }
    
    private func handleDeleteAction(_ request: DeleteActionRequest, on connection: NWConnection) {
        let success = deleteAction(withID: request.actionID)
        let response = ActionDeletedResponse(actionID: request.actionID, success: success, message: success ? "Action deleted successfully" : "Failed to delete action")
        if let message = Message.encodeMessage(type: .actionDeleted, payload: response) {
            send(message, on: connection)
        }
    }
    
    private func handleDeleteExecutor(_ request: DeleteExecutorRequest, on connection: NWConnection) {
        let success = deleteExecutor(widhtID: request.executorID)
        let response = ExecutorDeletedResponse(executorID: request.executorID, success: success, message: success ? "Executor deleted successfully" : "Failed to delete executor")
        if let message = Message.encodeMessage(type: .executorDeleted, payload: response) {
            send(message, on: connection)
        }
    }
    
    private func handleModifyExecutor(_ request: UpdateExecutorRequest, on connection: NWConnection) {
        let success = modifyExecutor(executor: request.executor)
        let response = ExecutorUpdatedResponse(executorID: request.executor.id, success: success, message: success ? "Executor modified successfully" : "Failed to modify executor")
        if let message = Message.encodeMessage(type: .executorUpdated, payload: response) {
            send(message, on: connection)
        }
    }
    
    private func handleSwapExecutor(_ request: SwapExecutorRequest, on connection: NWConnection) {
        let success = swapExecutor(withID: request.executorID, toPage: request.pageID, toIndex: request.index)
        let response = ExecutorSwappedResponse(executorID: request.executorID, success: success, message: success ? "Executor swapped successfully" : "Failed to swap executor")
        if let message = Message.encodeMessage(type: .executorSwapped, payload: response) {
            send(message, on: connection)
        }
    }
    
    // Send a Message to the connection
    func send(_ message: Message, on connection: NWConnection) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(message)
            // Convert to string and append newline
            if var jsonString = String(data: data, encoding: .utf8) {
                jsonString += "\n"
                if let messageData = jsonString.data(using: .utf8) {
                    connection.send(content: messageData, completion: .contentProcessed({ error in
                        if let error = error {
                            print("Send error: \(error)")
                        } else {
                            print("Sent message of type \(message.type.rawValue)")
                        }
                    }))
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }

    
    // Send an error message
    private func sendError(message: String, on connection: NWConnection) {
        let errorMessage = ErrorMessage(message: message)
        if let message = Message.encodeMessage(type: .error, payload: errorMessage) {
            send(message, on: connection)
        }
    }
    
    private func fetchPages() -> [PageModel] {
        return userData.pages
    }
    
    private func fetchActions() -> [ActionModel] {
        return userData.actions
    }
    
    private func executeAction(withID id: String) -> Bool {
        guard let action = userData.actions.first(where: { $0.id == id }) else { return false }
        print("Executing action \(action)")
        switch action.type {
        case .keybind:
            runKeybindAction(action)
        case .siriShortcut:
            runShortcutAction(action)
        }
        
        return true
    }
    
    private func createAction(action: ActionModel) -> Bool {
        userData.actions.append(action)
        return true
    }
    
    private func createExecutor(executor: ExecutorModel, pageID: String) -> Bool {

        if let pageIndex = userData.pages.firstIndex(where: { $0.id == pageID }) {
            userData.pages[pageIndex].executors.append(executor)
            return true
        }
        return false
    }
    
    private func deleteAction(withID id: String) -> Bool {
        if let index = userData.actions.firstIndex(where: {$0.id == id}) {
            userData.actions.remove(at: index)
            return true
        }
        return false
    }
    
    private func deleteExecutor(widhtID id: String) -> Bool {
        for pageIndex in userData.pages.indices {
            if let index = userData.pages[pageIndex].executors.firstIndex(where:{$0?.id == id}) {
                userData.pages[pageIndex].executors.remove(at: index)
                return true
            }
        }
        return false
    }
    
    private func modifyExecutor(executor: ExecutorModel) -> Bool {
        for pageIndex in userData.pages.indices {
            if let index = userData.pages[pageIndex].executors.firstIndex(where:{$0?.id == executor.id}) {
                userData.pages[pageIndex].executors[index] = executor
                return true
            }
        }
        return false
    }
    
    private func modifyAction(action: ActionModel) -> Bool {
        let changedIndex = userData.actions.firstIndex(where: { $0.id == action.id })
        if let index = changedIndex {
            userData.actions[index] = action
            return true
        }
        return false
    }
    
    private func swapExecutor(withID executorID: String, toPage pageID: String, toIndex index: Int) -> Bool {
        // Find the destination page index
        guard let destinationPageIndex = userData.pages.firstIndex(where: { $0.id == pageID }) else {
            return false
        }
        
        // Ensure the destination executors array is large enough
        while userData.pages[destinationPageIndex].executors.count <= index {
            userData.pages[destinationPageIndex].executors.append(nil)
        }
        
        // Iterate through pages to find the executor to swap
        for sourcePageIndex in userData.pages.indices {
            if let sourceIndex = userData.pages[sourcePageIndex].executors.firstIndex(where: { $0?.id == executorID }) {
                // Perform the swap
                let temp = userData.pages[destinationPageIndex].executors[index]
                userData.pages[destinationPageIndex].executors[index] = userData.pages[sourcePageIndex].executors[sourceIndex]
                userData.pages[sourcePageIndex].executors[sourceIndex] = temp
                return true
            }
        }
        
        // If executor not found, return false
        return false
    }

    private func removeConnection(_ connection: NWConnection) {
        if let index = connections.firstIndex(where: { $0 === connection }) {
            connections.remove(at: index)
        }
        // Remove the MessageReceiver for this connection
        messageReceivers.removeValue(forKey: ObjectIdentifier(connection))
        connection.cancel()
    }
    

}

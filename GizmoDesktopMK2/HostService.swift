//
//  HostService.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//
import Foundation
import Network
import ISSoundAdditions
import AppKit
import CoreGraphics

class HostService {
    private var listener: NWListener?
    public var connections: [NWConnection] = []
    
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
            case .executeAction:
                if let request = message.decodePayload(as: ExecuteActionRequest.self) {
                    handleExecuteAction(request, on: connection)
                }
            case .createExecutor:
                if let request = message.decodePayload(as: CreateExecutorRequest.self) {
                    handleCreateExecutor(request, on: connection)
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
            case .listApps:
                if let request = message.decodePayload(as: ListAppsRequest.self) {
                    handleListAppsRequest(request, on: connection)
                }
            case .createPage:
                if let request = message.decodePayload(as: CreatePageRequest.self) {
                    handleCreatePageRequest(request, on: connection)
                }
            case .modifyPage:
                if let request = message.decodePayload(as: ModifyPageRequest.self) {
                    handleModifyPageRequest(request, on: connection)
                }
            case .deletePage:
                if let request = message.decodePayload(as: DeletePageRequest.self) {
                    handleDeletePageRequest(request, on: connection)
                }
            case .updateAppInfo:
                if let request = message.decodePayload(as: UpdateAppInfoRequest.self) {
                    handleUpdateAppInfoRequest(request, on:connection)
                }
            case .getAppIcon:
                if let request = message.decodePayload(as: GetAppIconRequest.self) {
                    handleGetAppIconRequset(request, on: connection)
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
    
    func cgImageToData(_ cgImage: CGImage, format: NSBitmapImageRep.FileType = .png) -> Data? {
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: format, properties: [:])
    }
    
    private func handleGetAppIconRequset(_ request: GetAppIconRequest, on connection: NWConnection) {
        if let appInfo = self.userData.rememberedApps.first(where: { $0.bundleID == request.bundleID }) {
            guard let appIcon = appInfo.appIcon else {
                return
            }
            if let iconData = cgImageToData(appIcon) {
                let appIconDataResponse = AppIconDataResponse(bundleID: request.bundleID, iconData: iconData)
                if let message = Message.encodeMessage(type: .appIconData, payload: appIconDataResponse) {
                    send(message, on:connection)
                }
            }
        }
        
    }
    
    // Handle ListPagesRequest
    private func handleListPagesRequest(on connection: NWConnection) {
        let pagesList = PagesListResponse(pages: fetchPages())
        if let message = Message.encodeMessage(type: .pagesList, payload: pagesList) {
            send(message, on: connection)
        }
    }
    
    private func handleCreatePageRequest(_ request: CreatePageRequest, on connection: NWConnection) {
        let success = createPage(page: request.page)
        let pageUpdatedResponse = PageUpdatedResponse(pageID: request.page.id, success: success, message: "")
        if let message = Message.encodeMessage(type: .pageUpdated, payload: pageUpdatedResponse) {
            send(message, on: connection)
        }
    }
    
    private func handleModifyPageRequest(_ request: ModifyPageRequest, on connection: NWConnection) {
        let success = modifyPage(page: request.page)
        let pageUpdatedResponse = PageUpdatedResponse(pageID: request.page.id, success: success, message: "")
        if let message = Message.encodeMessage(type: .pageUpdated, payload: pageUpdatedResponse) {
            send(message, on: connection)
        }
    }
    
    private func handleUpdateAppInfoRequest(_ request: UpdateAppInfoRequest, on connection: NWConnection) {
        if let appIndex = self.userData.rememberedApps.firstIndex(where: { $0.bundleID == request.appInfo.bundleID }) {
            self.userData.rememberedApps[appIndex] = request.appInfo
            print("updated info to \(request.appInfo)")
        }
        else {
            
        }
    }
    
    private func handleDeletePageRequest(_ request: DeletePageRequest, on connection: NWConnection) {
        let page = deletePage(withID: request.pageID)
        if let message = Message.encodeMessage(type: .pageUpdated, payload: page) {
            send(message, on: connection)
        }
    }
    
    private func handleListShortcutsRequest(on connection: NWConnection) {
        let shortcuts = ShortcutsListResponse(shortcuts: fetchShortcuts())
        if let message = Message.encodeMessage(type: .shortcutsList, payload: shortcuts) {
            send(message, on: connection)
        }
    }
    
    
    // Handle ExecuteActionRequest
    private func handleExecuteAction(_ request: ExecuteActionRequest, on connection: NWConnection) {
        // Execute the action based on actionID
        let success = executeAction(executorId: request.executorID, actionContextOption: request.actionContextOption)
        let response = ActionExecutedResponse(executorId: request.executorID, success: success, message: success ? "Action executed successfully" : "Failed to execute action")
        if let message = Message.encodeMessage(type: .actionExecuted, payload: response) {
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
    
    private func handleListAppsRequest(_ request: ListAppsRequest, on connection: NWConnection) {
        updateAllInstalledApplications()
        let response = AppsListResponse(appInfos: userData.rememberedApps)
        if let message = Message.encodeMessage(type: .appsList, payload: response) {
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
    
    private func executeAction(executorId : String, actionContextOption : ActionContextOption) -> Bool {
        var executor : ExecutorModel?
        for pageIndex in userData.pages.indices {
            if let index = userData.pages[pageIndex].executors.firstIndex(where:{$0?.id == executorId}) {
                executor = userData.pages[pageIndex].executors[index]
                break;
            }
        }
        guard let executor = executor else {return false}
        let action = actionContextOption.correspondingActionModel(for: executor)
        print("Executing action \(action)")
        switch action.type {
        case .keybind:
            runKeybindAction(action)
        case .siriShortcut:
            runShortcutAction(action)
        case .volumeUp:
            Sound.output.increaseVolume(by: Float(action.numericValue), autoMuteUnmute: true)
        case .volumeDown:
            Sound.output.decreaseVolume(by: Float(action.numericValue), autoMuteUnmute: true)
        case .setVolume:
            Sound.output.volume = Float(action.numericValue)
        case .leftClick:
            performLeftClick()
        case .rightClick:
            performRightClick()
        default:
            print(action)
        }
        
        return true
    }
        
    private func createPage(page : PageModel) -> Bool {
        userData.pages.append(page)
        return true
    }
    
    private func modifyPage(page: PageModel) -> Bool {
        for pageIndex in userData.pages.indices {
            if userData.pages[pageIndex].id == page.id {
                userData.pages[pageIndex] = page
                print("New pages \(userData.pages)")
                return true
            }
        }
        return false
    }
    
    private func deletePage(withID id: String) -> Bool {
        if let index = userData.pages.firstIndex(where: {$0.id == id}) {
            userData.pages.remove(at: index)
            return true
        }
        return false
    }
    
    private func createExecutor(executor: ExecutorModel, pageID: String) -> Bool {

        if let pageIndex = userData.pages.firstIndex(where: { $0.id == pageID }) {
            userData.pages[pageIndex].executors.append(executor)
            return true
        }
        return false
    }

    
    private func deleteExecutor(widhtID id: String) -> Bool {
        for pageIndex in userData.pages.indices {
            if let index = userData.pages[pageIndex].executors.firstIndex(where:{$0?.id == id}) {
                userData.pages[pageIndex].executors[index] = nil
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
    
    public func focusedAppUpdated( appInfo : AppInfoModel ) {
        let updateFocusRequest = FocusedAppUpdateRequest(appInfo: appInfo)
        for connection in connections {
            if let message = Message.encodeMessage(type: .focusedAppUpdated, payload: updateFocusRequest) {
                send(message, on: connection)
            }
        }
    }

    private func removeConnection(_ connection: NWConnection) {
        if let index = connections.firstIndex(where: { $0 === connection }) {
            connections.remove(at: index)
        }
        // Remove the MessageReceiver for this connection
        messageReceivers.removeValue(forKey: ObjectIdentifier(connection))
        connection.cancel()
    }
    
 
    
    func updateAllInstalledApplications() {
        let fileManager = FileManager.default

        let applicationDirectories = [
            "/Applications",
            "/System/Applications",
            "/System/Library/CoreServices",
            "\(NSHomeDirectory())/Applications"
        ]

        for directoryPath in applicationDirectories {
            let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
            if let enumerator = fileManager.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                for case let fileURL as URL in enumerator {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.isDirectoryKey])
                        if resourceValues.isDirectory == true && fileURL.pathExtension == "app" {
                            if let bundle = Bundle(url: fileURL) {
                                let appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown"
                                let bundleID = bundle.bundleIdentifier ?? "Unknown"

                                // Try to retrieve the icon name
                                var iconFileName: String? = bundle.object(forInfoDictionaryKey: "CFBundleIconFile") as? String

                                // Check if `CFBundleIconName` is set (modern approach)
                                if iconFileName == nil {
                                    iconFileName = bundle.object(forInfoDictionaryKey: "CFBundleIconName") as? String
                                }

                                var iconURL: URL?

                                if let iconFile = iconFileName {
                                    // Ensure the file has the correct extension
                                    if !iconFile.hasSuffix(".icns") {
                                        iconURL = fileURL.appendingPathComponent("Contents/Resources/\(iconFile).icns")
                                    } else {
                                        iconURL = fileURL.appendingPathComponent("Contents/Resources/\(iconFile)")
                                    }
                                    
                                    // Check if file exists
                                    if let iconURL = iconURL, fileManager.fileExists(atPath: iconURL.path) {
                                        if let nsImage = NSImage(contentsOf: iconURL), let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                                            if let resizedIcon = cgImage.resize(size: CGSize(width: 50, height: 50)) {
                                                print("Loaded icon for \(appName)")
                                                
                                                if let appIndex = self.userData.rememberedApps.firstIndex(where: { $0.bundleID == bundleID }) {
                                                    self.userData.rememberedApps[appIndex].appIcon = resizedIcon
                                                } else {
                                                    var appInfo = AppInfoModel(name: appName, bundleID: bundleID)
                                                    appInfo.appIcon = resizedIcon
                                                    userData.rememberedApps.append(appInfo)
                                                }
                                            } else {
                                                print("Failed to resize icon for \(appName)")
                                            }
                                        } else {
                                            print("Failed to load icon for \(appName)")
                                        }
                                    } else {
                                        print("Icon file not found for \(appName) at \(iconURL?.path ?? "Unknown Path")")
                                    }
                                } else {
                                    print("No icon reference found in Info.plist for \(appName)")
                                }
                            }
                            enumerator.skipDescendants()
                        }
                    } catch {
                        print("Error accessing \(fileURL.path): \(error)")
                    }
                }
            }
        }
    }

    

}



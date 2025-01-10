//
//  Message.swift
//  GizmoDesktopMK2
//
//  Created by Matthew Sand on 11/7/24.
//

import Foundation

// Enum to differentiate message types
enum MessageType: String, Codable {
    case listPages
    case pagesList
    case listShortcuts
    case shortcutsList
    case listActions
    case actionsList
    case executeAction
    case actionExecuted
    case createAction
    case modifyAction
    case actionUpdated
    case deleteAction
    case actionDeleted
    case createExecutor
    case updateExecutor
    case deleteExecutor
    case executorUpdated
    case executorDeleted
    case swapExecutor
    case executorSwapped
    case focusedAppUpdated
    case listApps
    case appsList
    case createPage
    case modifyPage
    case deletePage
    case pageUpdated
    case updateAppInfo
    case AppInfoUpdated
    case error
    case executeShortcut
    case shortcutExecuted
}


// Base message structure
struct Message: Codable {
    let type: MessageType
    let payload: String?
}

// Payload structures for each message type

// 1. ListPages (Client Request)
struct ListPagesRequest: Codable { }

// 2. PagesList (Host Response)
struct PagesListResponse: Codable {
    let pages: [PageModel]
}

struct ListShortcutsRequest : Codable {
}

struct ShortcutsListResponse : Codable {
    let shortcuts: [String]
}



struct ListActionsRequest: Codable { }

struct ActionsListResponse : Codable {
    let actions: [ActionModel]
}

// 3. ExecuteAction (Client Request)
struct ExecuteActionRequest: Codable {
    let actionID: String
}

struct ExecuteShortcutRequest : Codable {
    let shortcut: String
}

// 4. ActionExecuted (Host Response)
struct ActionExecutedResponse: Codable {
    let actionID: String
    let success: Bool
    let message: String?
}

struct ShortcutExecutedResponse : Codable {
    let shortcut: String
    let success: Bool
    let message: String?
}

// 5. CreateAction (Client Request)
struct CreateActionRequest: Codable {
    let action : ActionModel
}

// 6. ModifyAction (Client Request)
struct ModifyActionRequest: Codable {
    let action: ActionModel
}

// 7. ActionUpdated (Host Response)
struct ActionUpdatedResponse: Codable {
    let actionID: String
    let success: Bool
    let message: String?
}

struct UpdateExecutorRequest: Codable {
    let executor: ExecutorModel
}

struct ExecutorUpdatedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}


struct DeleteExecutorRequest: Codable {
    let executorID: String
}

struct ExecutorDeletedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}


struct DeleteActionRequest: Codable {
    let actionID: String
}

struct CreateExecutorRequest: Codable {
    let executor: ExecutorModel
    let pageID: String
}

struct ActionDeletedResponse: Codable {
    let actionID: String
    let success: Bool
    let message: String?
}

struct SwapExecutorRequest: Codable {
    let executorID: String
    let pageID: String
    let index : Int
}

struct ExecutorSwappedResponse : Codable {
    let executorID: String
    let success: Bool
    let message: String?
}

struct FocusedAppUpdateRequest : Codable {
    let appInfo : AppInfoModel
}

struct ListAppsRequest : Codable {
    
}

struct AppsListResponse : Codable {
    let appInfos : [AppInfoModel]
}

struct CreatePageRequest : Codable {
    let page : PageModel
}

struct ModifyPageRequest : Codable {
    let page : PageModel
}

struct DeletePageRequest : Codable {
    let pageID: String
}

struct PageUpdatedResponse : Codable {
    let pageID: String
    let success: Bool
    let message: String?
}

struct UpdateAppInfoRequest : Codable {
    let appInfo : AppInfoModel
}

struct AppInfoUpdatedResponse : Codable {
    let appInfoID: String
    let success: Bool
    let message: String?
}




// 8. Error Message
struct ErrorMessage: Codable {
    let message: String
}



extension Message {
    // Encode a specific payload into a Message
    static func encodeMessage<T: Codable>(type: MessageType, payload: T) -> Message? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(payload)
            let payloadString = data.base64EncodedString()
            return Message(type: type, payload: payloadString)
        } catch {
            print("Failed to encode payload: \(error)")
            return nil
        }
    }

    
    // Decode a Message's payload into a specific type
    func decodePayload<T: Codable>(as type: T.Type) -> T? {
        guard let payloadString = payload, let payloadData = Data(base64Encoded: payloadString) else {
            print("Payload is nil or invalid Base64 string.")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: payloadData)
        } catch {
            print("Failed to decode payload as \(T.self): \(error)")
            return nil
        }
    }

}


// Utility class to handle message framing
class MessageReceiver {
    private var buffer = Data()
    private let delimiter = "\n".data(using: .utf8)!
    
    func receive(data: Data, process: (Data) -> Void) {
        buffer.append(data)
        
        while let range = buffer.range(of: delimiter) {
            let messageData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            process(messageData)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
        }
    }
}




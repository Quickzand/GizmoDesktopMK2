import Foundation
import Network

// Structure representing a client discovered over Bonjour
struct FoundClient {
    let name: String
    let ipAddress: String
    let port: Int
}


// HostAppState for GizmoDesktopMK2
class AppState: ObservableObject {
    private let bonjourService = HostService()
    
    @Published var pages = [PageModel].self

}

import Foundation
import Network
import AppKit
import CoreServices


// Structure representing a client discovered over Bonjour
struct FoundClient {
    let name: String
    let ipAddress: String
    let port: Int
}




// HostAppState for GizmoDesktopMK2
class AppState: ObservableObject {
    @Published var bonjourService = HostService()
    
    @Published var pages = [PageModel].self
    
    @Published var focusedApp : AppInfoModel = .init(name: "", bundleID: "")
    
    init() {
        trackFocusedApp()
    }
    
    func trackFocusedApp() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo,
               let app = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                // Modify the properties of self
                self.focusedApp = AppInfoModel(name: app.localizedName ?? "Unknown", bundleID: app.bundleIdentifier ?? "Unknown")
                if let focusedAppInfo = self.bonjourService.userData.rememberedApps.first(where: { $0.bundleID == self.focusedApp.bundleID }) {
                    self.focusedApp = focusedAppInfo
                }
                bonjourService.focusedAppUpdated(appInfo: focusedApp)
            }
        }
    }

}




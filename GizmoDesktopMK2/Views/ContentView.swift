import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
            List {
                DisclosureGroup("Pages:") {
                    ScrollView {
                        ForEach(appState.bonjourService.userData.pages) {page in
                            HStack {
                                Text(page.name)
                                Spacer()
                            }
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxHeight: 200)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}

import SwiftUI

enum LoaderStatus {
    case LOADING
    case DONE
    case ERROR
}



enum Screen {
    case MENU
    case SHOP
    case ACHIVE
    case SETTINGS
    case GAME
}

class OrientationManager: ObservableObject  {
    @Published var isHorizontalLock = true {
            didSet {
                // При изменении isHorizontalLock уведомляем систему
                DispatchQueue.main.async {
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
        }
    
    static var shared: OrientationManager = .init()
}

struct RootView: View {
    @State private var status: LoaderStatus = .LOADING
    @ObservedObject private var nav: NavGuard = NavGuard.shared
    let url: URL = URL(string: "https://wayofcherokee.top/log")!
    
    @ObservedObject private var orientationManager: OrientationManager = OrientationManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if status != .DONE {
                    switch nav.currentScreen {
                    case .MENU:
                        MenuView()
                    case .SHOP:
                        ShopView()
                    case .ACHIVE:
                        AchiveView()
                    case .SETTINGS:
                        SettingsView()
                    case .GAME:
                        Game()
                    }
                }
            
                switch status {
                case .LOADING:
                    LoadingScreen()
                        .edgesIgnoringSafeArea(.all)
                case .DONE:
                    GameLoader_1E6704B4Overlay(data: .init(url: url))
                        
                case .ERROR:
                    Text("")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }

        .onAppear {
            Task {
                let result = await GameLoader_1E6704B4StatusChecker().checkStatus(url: url)
                if result {
                    self.status = .DONE
                } else {
                    self.status = .ERROR
                }
                print(result)
            }
        }
    }
}



#Preview {
    RootView()
}

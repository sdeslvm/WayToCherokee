import Foundation


enum AvailableScreens {
    case MENU
    case LOADING
    case PLEASURE
    case SHOP
    case ACHIVE
    case SETTINGS
    case GAME
}

class NavGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .LOADING
    static var shared: NavGuard = .init()
}

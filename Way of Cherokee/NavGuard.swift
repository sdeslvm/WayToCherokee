import Foundation


enum AvailableScreens {
    case MENU
    case SHOP
    case ACHIVE
    case SETTINGS
    case GAME
}

class NavGuard: ObservableObject {
    @Published var currentScreen: AvailableScreens = .MENU
    static var shared: NavGuard = .init()
}

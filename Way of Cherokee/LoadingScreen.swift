import SwiftUI

struct LoadingScreen: View {
    @State private var currentWheelImageIndex = 0
    @State private var isAnimating = true
    @State private var progress: Int = 0
    @State private var isActive = false
    @State private var urlToLoad: URL?
    @AppStorage("isNeeded") private var isNeeded: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    Image(.backgroundLoading)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.32)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

#Preview {
    LoadingScreen()
}

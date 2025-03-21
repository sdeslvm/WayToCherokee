import SwiftUI

struct MenuView: View {
    

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                VStack {
                    HStack {
                        Spacer()
                        ButtonTemplateSmall(image: "settingsBtn", action: {NavGuard.shared.currentScreen = .SETTINGS})
                            .padding(.top, 5)
                    }
                    Spacer()
                }
                        HStack {
                            Spacer()
                            VStack(spacing: 15)  {
                                ButtonTemplateBig(image: "playBtn", action: {NavGuard.shared.currentScreen = .GAME})
                                ButtonTemplateBig(image: "shopBtn", action: {NavGuard.shared.currentScreen = .SHOP})
                                
                                ButtonTemplateBig(image: "achiveBtn", action: {NavGuard.shared.currentScreen = .ACHIVE})
                            }
                           
                        }
                        .padding(.top, 50)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundMenu)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.1)
            )

        }
    }
}



struct BalanceTemplate: View {
    @AppStorage("coinscore") var coinscore: Int = 10
    
    var body: some View {
        ZStack {
            Image("balanceTemplate")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 70)
                .overlay(
                    ZStack {
                        Text("\(coinscore)")
                            .foregroundColor(.white)
                            .fontWeight(.heavy)
                            .font(.title3)
                            .position(x: 85, y: 35)
                    }
                )
        }
    }
}



struct ButtonTemplateSmall: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}

struct ButtonTemplateBig: View {
    var image: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 100)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }
    }
}



#Preview {
    MenuView()
}


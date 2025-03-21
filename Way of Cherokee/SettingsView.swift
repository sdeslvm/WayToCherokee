import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = CheckingSound()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                    ZStack {
                        
                        VStack {
                            HStack {
                                Image("back")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                    .foregroundStyle(.white)
                                    .onTapGesture {
                                        NavGuard.shared.currentScreen = .MENU
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                        
                        Image(.shopPlate)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 550, height: 350)
                        
                        HStack(spacing: 30) {
                                
                            VStack {
                                if settings.musicEnabled {
                                    Image(.musicOn)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 80)
                                        .onTapGesture {
                                            settings.musicEnabled.toggle()
                                        }
                                } else {
                                    Image(.musicOff)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 80)
                                        .onTapGesture {
                                            settings.musicEnabled.toggle()
                                        }
                                }
                            
                                if settings.soundEnabled {
                                    Image(.soundOn)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 80)
                                        .onTapGesture {
                                            settings.soundEnabled.toggle()
                                        }
                                } else {
                                    Image(.soundOff)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 130, height: 80)
                                        .onTapGesture {
                                            settings.soundEnabled.toggle()
                                        }
                                }
                            
                            }
                                                        
                        }

                        
                        
                        
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundSettings)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .scaleEffect(1.05)
            )
        }
    }
}

extension SettingsView {
    func openURLInSafari(urlString: String) {
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Не удалось открыть URL: \(urlString)")
            }
        } else {
            print("Неверный формат URL: \(urlString)")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SoundManager.shared)
}



import SwiftUI

struct AchiveView: View {
    @AppStorage("achive1") var achive1: Int = 0
    @AppStorage("achive2") var achive2: Int = 0
    
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
                                .padding(.top, 40)
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    NavGuard.shared.currentScreen = .MENU
                                }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    
                    Image("shopPlate")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 70)
                    
                    
                    VStack {
                        HStack {
                            if achive1 > 120 {
                                Image(.achive1Open)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            } else {
                                Image(.achive1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            }
                            
                            if achive2 > 150 {
                                Image(.achive2Open)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            } else {
                                Image(.achive2)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            }
                        }
                        .padding(.top, 40)
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    Image(.backgroundAchive)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .scaleEffect(1.1)
                )
                
            }
        }
    }
}



#Preview {
    AchiveView()
}


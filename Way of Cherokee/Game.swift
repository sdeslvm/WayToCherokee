import SwiftUI

struct RegionView: View {
    let owner: String
    let troops: Int
    let position: CGPoint
    
    private let templates = ["template", "template1", "template2", "template3", "template5", "template6"]
    
    @State private var selectedTemplate: String
    
    // Инициализатор для установки шаблона один раз
    init(owner: String, troops: Int, position: CGPoint) {
        self.owner = owner
        self.troops = troops
        self.position = position
        self._selectedTemplate = State(initialValue: ["template", "template1", "template2", "template3", "template5", "template6"].randomElement() ?? "template")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(owner == "player" ? "player" : (owner == "enemy" ? "enemy" : "netral"))
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("\(troops)")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        }
        .background(
            Circle() // Заменяем Image на Circle
                .fill(
                    owner == "player" ? Color.blue :
                    owner == "enemy" ? Color.red :
                    Color.gray // Цвет для нейтрального владельца
                )
                .opacity(0.5)
                .frame(width: 100, height: 100) // Размер круга
        )
        .position(position)
    }
}

// Структура для вертикального ползунка доминирования
struct DominanceSlider: View {
    let playerRegions: Int
    let enemyRegions: Int
    let totalRegions: Int
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 20, height: geometry.size.height * CGFloat(enemyRegions) / CGFloat(totalRegions))
                
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: 20, height: geometry.size.height * CGFloat(totalRegions - playerRegions - enemyRegions) / CGFloat(totalRegions))
                
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 20, height: geometry.size.height * CGFloat(playerRegions) / CGFloat(totalRegions))
            }
            .overlay(
                VStack {
                    Text("\(Int(CGFloat(enemyRegions) / CGFloat(totalRegions) * 100))%")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(Int(CGFloat(playerRegions) / CGFloat(totalRegions) * 100))%")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
                .padding(.vertical, 5)
            )
            .cornerRadius(10)
        }
    }
}

struct Game: View {
    // Теперь координаты задаются как доли от ширины и высоты (от 0 до 1)
    @State private var regions: [(id: Int, owner: String, troops: Int, relativePosition: CGPoint, requiredTroops: Int)] = [
        (0, "player", 20, CGPoint(x: 0.2, y: 0.5), 0),   // было y: 0.4, стало y: 0.5
        (1, "enemy", 5, CGPoint(x: 0.7, y: 0.4), 8),     // было y: 0.3, стало y: 0.4
        (2, "neutral", 15, CGPoint(x: 0.25, y: 0.3), 11), // было y: 0.2, стало y: 0.3
        (4, "neutral", 10, CGPoint(x: 0.5, y: 0.3), 11),  // было y: 0.2, стало y: 0.3
        (5, "neutral", 35, CGPoint(x: 0.35, y: 0.6), 11), // было y: 0.5, стало y: 0.6
        (6, "neutral", 20, CGPoint(x: 0.5, y: 0.5), 11),  // было y: 0.4, стало y: 0.5
        (7, "neutral", 45, CGPoint(x: 0.28, y: 0.7), 11), // было y: 0.6, стало y: 0.7
        (8, "neutral", 30, CGPoint(x: 0.65, y: 0.6), 11), // было y: 0.5, стало y: 0.6
        (9, "neutral", 40, CGPoint(x: 0.42, y: 0.74), 11), // было y: 0.64, стало y: 0.74
        (11, "neutral", 50, CGPoint(x: 0.7, y: 0.7), 11),  // было y: 0.6, стало y: 0.7
        (13, "neutral", 28, CGPoint(x: 0.57, y: 0.8), 11)  // было y: 0.7, стало y: 0.8
    ]
    
    @State private var selectedRegion: Int? = nil
    @State private var troopsInTransit: [(id: UUID, position: CGPoint, destination: CGPoint, targetIndex: Int, owner: String)] = []
    @State private var playerTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var enemyTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State private var attackLineEnd: CGPoint? = nil
    @State private var gameOver: Bool = false

    private var playerRegions: Int {
        regions.filter { $0.owner == "player" }.count
    }
    private var enemyRegions: Int {
        regions.filter { $0.owner == "enemy" }.count
    }
    private var totalRegions: Int {
        regions.count
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.templateBig)
                    .resizable()
                    .scaledToFit()
                
                if gameOver {
                    if playerRegions == totalRegions {
                        WinView()
                    } else if enemyRegions == totalRegions {
                        LoseView()
                    }
                } else {
                    if let start = selectedRegion, let end = attackLineEnd {
                        Path { path in
                            path.move(to: absolutePosition(regions[start].relativePosition, in: geometry))
                            path.addLine(to: end)
                        }
                        .stroke(Color.yellow, lineWidth: 2)
                        .zIndex(1)
                    }
                    
                    VStack {
                        HStack {
                            Image("back")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .onTapGesture {
                                    NavGuard.shared.currentScreen = .MENU
                                }
                                .padding()
                            Spacer()
                        }
                        Spacer()
                    }

                    // Отрисовка регионов с адаптивными позициями
                    ForEach(regions.indices, id: \.self) { index in
                        let region = regions[index]
                        let absolutePos = absolutePosition(region.relativePosition, in: geometry)
                        RegionView(owner: region.owner, troops: region.troops, position: absolutePos)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if selectedRegion == nil && region.owner == "player" && region.troops > 1 {
                                            selectedRegion = index
                                            attackLineEnd = absolutePos
                                        }
                                        if selectedRegion != nil {
                                            attackLineEnd = value.location
                                        }
                                    }
                                    .onEnded { value in
                                        if let sourceIndex = selectedRegion {
                                            handleAttackEnd(at: value.location, from: sourceIndex, geometry: geometry)
                                        }
                                        selectedRegion = nil
                                        attackLineEnd = nil
                                    }
                            )
                    }

                    ForEach(troopsInTransit, id: \.id) { troop in
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(troop.owner == "player" ? .green : .orange)
                            .position(troop.position)
                            .animation(.linear(duration: 1.0), value: troop.position)
                            .zIndex(2)
                    }

                    HStack {
                        Spacer()
                        DominanceSlider(playerRegions: playerRegions, enemyRegions: enemyRegions, totalRegions: totalRegions)
                            .frame(width: 20, height: 300)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                Image(.backgroundGame)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.42)
            )
            .onReceive(playerTimer) { _ in
                if !gameOver {
                    for i in regions.indices {
                        if regions[i].owner == "player" || regions[i].owner == "enemy" {
                            regions[i].troops += 1
                        }
                    }
                    updateTroopsInTransit(geometry: geometry)
                    checkGameOver()
                }
            }
            .onReceive(enemyTimer) { _ in
                if !gameOver {
                    enemyAttack(geometry: geometry)
                    checkGameOver()
                }
            }
        }
    }

    // Перевод относительных координат в абсолютные
    private func absolutePosition(_ relative: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        CGPoint(x: relative.x * geometry.size.width, y: relative.y * geometry.size.height)
    }

    private func handleAttackEnd(at point: CGPoint, from sourceIndex: Int, geometry: GeometryProxy) {
        var isPad = UIDevice.current.userInterfaceIdiom == .pad

        if let targetIndex = findTargetRegion(at: point, geometry: geometry), targetIndex != sourceIndex {
            let sourcePos = absolutePosition(regions[sourceIndex].relativePosition, in: geometry)
            let targetPos = absolutePosition(regions[targetIndex].relativePosition, in: geometry)
            let dist = distance(from: sourcePos, to: targetPos)
            if dist < (isPad ? 450 : 150) {
                let troopsToSend = regions[sourceIndex].troops
                let requiredTroops = regions[targetIndex].requiredTroops
                if troopsToSend >= requiredTroops {
                    regions[sourceIndex].troops = 0
                    spawnTroops(from: sourceIndex, to: targetIndex, count: troopsToSend, owner: "player", geometry: geometry)
                }
            }
        }
    }

    private func spawnTroops(from sourceIndex: Int, to targetIndex: Int, count: Int, owner: String, geometry: GeometryProxy) {
        let sourcePos = absolutePosition(regions[sourceIndex].relativePosition, in: geometry)
        let targetPos = absolutePosition(regions[targetIndex].relativePosition, in: geometry)
        for i in 0..<count {
            let troopID = UUID()
            let offsetX = CGFloat.random(in: -5...5)
            let offsetY = CGFloat.random(in: -5...5)
            let initialPos = CGPoint(x: sourcePos.x + offsetX, y: sourcePos.y + offsetY)
            troopsInTransit.append((id: troopID, position: initialPos, destination: targetPos, targetIndex: targetIndex, owner: owner))
        }
    }

    private func updateTroopsInTransit(geometry: GeometryProxy) {
        var troopsArrived = [Int: (player: Int, enemy: Int)]()
        for i in troopsInTransit.indices.reversed() {
            let troop = troopsInTransit[i]
            let newPos = moveToward(from: troop.position, to: troop.destination, speed: 40)
            let distToDest = distance(from: newPos, to: troop.destination)
            troopsInTransit[i].position = newPos

            if distToDest < 5 {
                if troop.owner == "player" {
                    troopsArrived[troop.targetIndex, default: (0, 0)].player += 1
                } else {
                    troopsArrived[troop.targetIndex, default: (0, 0)].enemy += 1
                }
                troopsInTransit.remove(at: i)
            }
        }

        for (targetIndex, (playerTroops, enemyTroops)) in troopsArrived {
            let currentTroops = regions[targetIndex].troops
            let currentOwner = regions[targetIndex].owner
            if playerTroops > 0 && enemyTroops > 0 {
                let result = playerTroops - enemyTroops
                if result > 0 {
                    regions[targetIndex].owner = "player"
                    regions[targetIndex].troops = result
                } else if result < 0 {
                    regions[targetIndex].owner = "enemy"
                    regions[targetIndex].troops = -result
                } else {
                    regions[targetIndex].troops = 0
                }
            } else if playerTroops > 0 {
                if currentOwner == "neutral" || currentOwner == "enemy" {
                    let result = playerTroops - currentTroops
                    if result > 0 {
                        regions[targetIndex].owner = "player"
                        regions[targetIndex].troops = result
                    } else if result < 0 {
                        regions[targetIndex].troops = -result
                    } else {
                        regions[targetIndex].troops = 0
                    }
                }
            } else if enemyTroops > 0 {
                if currentOwner == "neutral" || currentOwner == "player" {
                    let result = enemyTroops - currentTroops
                    if result > 0 {
                        regions[targetIndex].owner = "enemy"
                        regions[targetIndex].troops = result
                    } else if result < 0 {
                        regions[targetIndex].troops = -result
                    } else {
                        regions[targetIndex].troops = 0
                    }
                }
            }
        }
    }

    private func enemyAttack(geometry: GeometryProxy) {
        for i in regions.indices where regions[i].owner == "enemy" && regions[i].troops > 1 {
            if let targetIndex = findNearestTarget(from: i, geometry: geometry) {
                let troopsToSend = regions[i].troops
                let requiredTroops = regions[targetIndex].requiredTroops
                if troopsToSend >= requiredTroops {
                    regions[i].troops = 0
                    spawnTroops(from: i, to: targetIndex, count: troopsToSend, owner: "enemy", geometry: geometry)
                }
            }
        }
    }

    private func findTargetRegion(at point: CGPoint, geometry: GeometryProxy) -> Int? {
        regions.firstIndex { distance(from: absolutePosition($0.relativePosition, in: geometry), to: point) < 40 }
    }

    private func findNearestTarget(from sourceIndex: Int, geometry: GeometryProxy) -> Int? {
        var isPad = UIDevice.current.userInterfaceIdiom == .pad
        var nearestIndex: Int? = nil
        var minDistance: CGFloat = isPad ? 450 : 150
        for i in regions.indices where i != sourceIndex && regions[i].owner != "enemy" {
            let dist = distance(from: absolutePosition(regions[sourceIndex].relativePosition, in: geometry),
                              to: absolutePosition(regions[i].relativePosition, in: geometry))
            if dist < minDistance {
                minDistance = dist
                nearestIndex = i
            }
        }
        return nearestIndex
    }

    private func moveToward(from: CGPoint, to: CGPoint, speed: CGFloat) -> CGPoint {
        let dist = distance(from: from, to: to)
        if dist < speed { return to }
        let angle = atan2(to.y - from.y, to.x - from.x)
        return CGPoint(x: from.x + speed * cos(angle), y: from.y + speed * sin(angle))
    }

    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }

    private func checkGameOver() {
        if playerRegions == totalRegions || enemyRegions == totalRegions {
            gameOver = true
            playerTimer.upstream.connect().cancel()
            enemyTimer.upstream.connect().cancel()
        }
    }
}

struct WinView: View {
    @AppStorage("coinscore") var coinscore: Int = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.winPlate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.22)
                    .onTapGesture {
                        coinscore += 50
                        NavGuard.shared.currentScreen = .MENU
                    }
            }
        }
    }
}

struct LoseView: View {
    @AppStorage("coinscore") var coinscore: Int = 10

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(.losePlate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(1.22)
                    .onTapGesture {
                        NavGuard.shared.currentScreen = .MENU
                    }
            }
        }
    }
}

#Preview {
    Game()
}

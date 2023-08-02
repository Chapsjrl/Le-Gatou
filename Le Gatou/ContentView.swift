//
//  ContentView.swift
//  Le Gatou
//
//  Created by Alejandro Rivera on 01/08/23.
//

import SwiftUI

struct ContentView: View {
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameBoardDisable = false
    
    let columns: [GridItem] = [GridItem(.flexible()),
                                 GridItem(.flexible()),
                                 GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Circle()
                                .foregroundColor(Color.mint).opacity(0.8)
                                .frame(width: geometry.size.width/3 - 15,
                                       height: geometry.size.width/3 - 15)
                            
                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.gray)
                        }
                        .onTapGesture {
                            if isSquareOccupied(in: moves, forIndex: i) { return }
                            moves[i] = Move(player: .human, boardIndex: i)
                            isGameBoardDisable = true
                            
                            // Check win or Draw
                            guard !checkWinCondition(for: .human, in: moves) else { return }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                                guard !checkWinCondition(for: .computer, in: moves) else { return }
                                isGameBoardDisable = false
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .disabled(isGameBoardDisable)
        .padding()
        .background(Color.gray.gradient)
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        moves.contains(where: { $0?.boardIndex == index})
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func checkWinCondition(for player: Player, in move: [Move?]) -> Bool {
        let winPatterns: Set<Set<Int>> = [[0,1,2],[3,4,5],[6,7,8],
                                          [0,3,6],[1,4,7],[2,5,8],
                                          [0,4,8],[6,4,2]]
        let playerMoves = moves.compactMap({$0}).filter({$0.player == player})
        let playerPositions = Set(playerMoves.map(\.boardIndex))
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
}

enum Player {
    case human, computer
    
    var indicator: String {
        switch self {
        case .human:
            return "xmark"
        case .computer:
            return "circle"
        }
    }
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String { player.indicator }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

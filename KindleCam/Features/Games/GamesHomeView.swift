//
//  ContentView.swift
//  gameForKids
//

import SwiftUI

private enum GameActiveScreen {
    case cardSelection
    case game(GameCategory)
    case cheer(GameCategory)
}

struct GamesHomeView: View {
    @StateObject private var progressManager = GameProgressManager()
    @State private var activeScreen: GameActiveScreen = .cardSelection

    var body: some View {
        ZStack {
            switch activeScreen {
            case .cardSelection:
                CardSelectionView(
                    progressManager: progressManager,
                    onSelectCategory: { category in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeScreen = .game(category)
                        }
                    }
                )
                .transition(.opacity)

            case .game(let category):
                switch category {
                case .counting:
                    CountGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.counting)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .sequence:
                    SequenceGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.sequence)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .wordCompletion:
                    WordGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.wordCompletion)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .matchShadow:
                    ShadowGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.matchShadow)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .findOddOne:
                    OddOneGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.findOddOne)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .memoryGame:
                    MemoryGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.memoryGame)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .sizeComparison:
                    SizeGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.sizeComparison)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .shapeExplorer:
                    ShapeGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.shapeExplorer)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .animalWorld:
                    AnimalGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.animalWorld)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))

                case .mathFun:
                    MathGameView(
                        progressManager: progressManager,
                        onFinishCategory: {
                            withAnimation(.spring()) {
                                activeScreen = .cheer(.mathFun)
                            }
                        },
                        onBackToHome: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                activeScreen = .cardSelection
                            }
                        }
                    )
                    .transition(.move(edge: .trailing))
                }

            case .cheer(let category):
                CheerFeedbackView(
                    category: category,
                    onBackToCardSelection: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeScreen = .cardSelection
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }
}

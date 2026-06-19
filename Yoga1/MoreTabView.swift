import SwiftUI

public struct MoreTabView: View {
    @Environment(AppStateManager.self) private var appState
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Аккаунт") {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.mint)
                        VStack(alignment: .leading) {
                            Text("Пользователь")
                                .font(.headline)
                            Text(appState.isPremiumActivated ? "Premium План 👑" : "Свободный план")
                                .font(.caption)
                                .foregroundStyle(appState.isPremiumActivated ? .yellow : .secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                if !appState.earnedAchievements.isEmpty {
                    Section("Достижения") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(appState.earnedAchievements, id: \.self) { badge in
                                    VStack {
                                        Image(systemName: "medal.fill")
                                            .font(.title)
                                            .foregroundStyle(.yellow)
                                            .padding()
                                            .background(Color.mint.opacity(0.2), in: Circle())
                                        Text(badge)
                                            .font(.caption)
                                            .bold()
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                Section("Настройки") {
                    NavigationLink("Уведомления") {
                        Text("Настройки уведомлений")
                    }
                    NavigationLink("Apple Health") {
                        Text("Синхронизация с HealthKit")
                    }
                }
                
                Section("Информация") {
                    Link("Поддержка", destination: URL(string: "https://example.com/support")!)
                    Link("Политика конфиденциальности", destination: URL(string: "https://example.com/privacy")!)
                }
                
                Section {
                    Button(role: .destructive, action: {
                        appState.reset()
                    }) {
                        Text("Выйти из аккаунта")
                    }
                }
            }
            .navigationTitle("Профиль")
        }
    }
}

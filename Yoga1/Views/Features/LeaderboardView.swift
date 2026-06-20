internal import SwiftUI

/// Community leaderboard backed by Firestore (with a sample fallback). Players
/// compete on practice minutes, streak length or total XP, and a rotating
/// community challenge highlights the current leader.
struct LeaderboardView: View {
    @Environment(AppState.self) private var app

    @State private var scope: LeaderboardScope = .minutes
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var selectedAchievement: AchievementDefinition? = nil
    @State private var showingShareSheet = false

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    private var me: LeaderboardEntry {
        LeaderboardEntry(
            id: app.currentUserId,
            name: app.displayName,
            minutes: app.completedMinutes,
            streak: app.streakDays,
            xp: app.totalXP,
            level: app.level
        )
    }

    private var myRank: Int? {
        entries.firstIndex { $0.id == app.currentUserId }.map { $0 + 1 }
    }

    var body: some View {
        ZStack {
            // Premium background
            Color.black.ignoresSafeArea()

            // Dynamic ambient background glow
            VStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.12))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -60, y: -60)
                Spacer()
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- CUSTOM CAPSULE SCOPE PICKER ---
                    HStack(spacing: 4) {
                        ForEach(LeaderboardScope.allCases) { s in
                            let isSelected = (scope == s)
                            Button {
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.76)) {
                                    scope = s
                                }
                                HapticsManager.shared.playLightImpact()
                            } label: {
                                Text(s.title)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(isSelected ? .black : .white.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        isSelected ?
                                        AnyShapeStyle(Color.white) :
                                        AnyShapeStyle(Color.clear)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
                    .padding(.horizontal, 4)

                    // --- COMMUNITY CHALLENGE BENTO CARD ---
                    ChallengeBanner(scope: scope, leader: entries.first)

                    // --- ACHIEVEMENTS BENTO GRID SECTION ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isRussian ? "Сетка достижений" : "Achievements Bento Grid")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 4)
                        
                        // Interactive Asymmetric Bento Grid
                        VStack(spacing: 12) {
                            // Row 1
                            HStack(spacing: 12) {
                                achievementBentoCell(forKey: "achievement.first_step", isLarge: false)
                                achievementBentoCell(forKey: "achievement.streak_7", isLarge: true)
                            }
                            
                            // Row 2
                            HStack(spacing: 12) {
                                achievementBentoCell(forKey: "achievement.streak_30", isLarge: true)
                                achievementBentoCell(forKey: "achievement.zen", isLarge: false)
                            }
                            
                            // Row 3
                            HStack(spacing: 12) {
                                achievementBentoCell(forKey: "achievement.vip", isLarge: false)
                                achievementBentoCell(forKey: "achievement.mastery_5", isLarge: false)
                                achievementBentoCell(forKey: "achievement.breath_guru", isLarge: false)
                            }
                            
                            // Row 4
                            HStack(spacing: 12) {
                                achievementBentoCell(forKey: "achievement.early_yogi", isLarge: true)
                                achievementBentoCell(forKey: "achievement.journal_entry", isLarge: false)
                            }
                        }
                    }

                    // --- LEADERBOARD ENTRIES SECTION ---
                    VStack(alignment: .leading, spacing: 14) {
                        Text(isRussian ? "Рейтинг Сообщества" : "Community Standings")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 4)

                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(.mint)
                                    .padding(.vertical, 30)
                                Spacer()
                            }
                        } else {
                            VStack(spacing: 10) {
                                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                    LeaderboardRow(
                                        rank: index + 1,
                                        entry: entry,
                                        scope: scope,
                                        isCurrentUser: entry.id == app.currentUserId
                                    )
                                }
                            }

                            if let rank = myRank {
                                Text(isRussian ? "Ваш ранг: #\(rank)" : "You're ranked #\(rank)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(isRussian ? "Лига и испытания" : "Leaderboard")
        .navigationBarTitleDisplayMode(.large)
        .task(id: scope) { await load() }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement, isUnlocked: app.earnedAchievements.contains(achievement.id))
        }
    }

    private func load() async {
        isLoading = true
        entries = await FirebaseManager.shared.fetchLeaderboard(scope: scope, currentUser: me)
        isLoading = false
    }

    // --- CELL RENDERER ---
    @ViewBuilder
    private func achievementBentoCell(forKey key: String, isLarge: Bool) -> some View {
        if let def = AchievementDefinition.allAchievements.first(where: { $0.id == key }) {
            let isUnlocked = app.earnedAchievements.contains(key)
            
            Button {
                HapticsManager.shared.playLightImpact()
                selectedAchievement = def
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        let imageName = def.id.replacingOccurrences(of: ".", with: "_")
                        if UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                                .saturation(isUnlocked ? 1.0 : 0.0)
                                .opacity(isUnlocked ? 1.0 : 0.4)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(isUnlocked ? LinearGradient(colors: def.gradient.map { $0.opacity(0.2) }, startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [Color.white.opacity(0.04)], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: def.icon)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(isUnlocked ? LinearGradient(colors: def.gradient, startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.white.opacity(0.25)], startPoint: .top, endPoint: .bottom))
                            }
                        }
                        
                        Spacer()
                        
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.2))
                                .padding(5)
                                .background(Color.white.opacity(0.04), in: Circle())
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(def.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        if isLarge {
                            Text(def.description)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(isUnlocked ? .white.opacity(0.6) : .white.opacity(0.25))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(12)
                .frame(height: 90)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    isUnlocked ?
                    AnyShapeStyle(
                        LinearGradient(colors: def.gradient.map { $0.opacity(0.08) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) :
                    AnyShapeStyle(Color.white.opacity(0.03))
                )
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(
                            isUnlocked ?
                            LinearGradient(colors: def.gradient.map { $0.opacity(0.3) }, startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom),
                            lineWidth: 1.2
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Community challenge banner

private struct ChallengeBanner: View {
    let scope: LeaderboardScope
    let leader: LeaderboardEntry?

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    private var title: String {
        switch scope {
        case .minutes: return isRussian ? "Испытание: Время Практики" : "Practice Challenge"
        case .streak:  return isRussian ? "Испытание: Регулярность" : "Streak Challenge"
        case .xp:      return isRussian ? "Испытание: Лидеры XP" : "XP Mastery Challenge"
        }
    }

    private var leaderLine: String {
        guard let leader else {
            return isRussian ? "Испытание активно. Станьте первым!" : "Challenge active. Take the lead!"
        }
        
        switch scope {
        case .minutes: 
            return isRussian 
                ? "\(leader.name) лидирует с \(leader.minutes) мин" 
                : "\(leader.name) leads with \(leader.minutes) min"
        case .streak:  
            return isRussian 
                ? "\(leader.name) лидирует с серией в \(leader.streak) дн." 
                : "\(leader.name) leads with a \(leader.streak)-day streak"
        case .xp:      
            return isRussian 
                ? "\(leader.name) лидирует с \(leader.xp) XP" 
                : "\(leader.name) leads with \(leader.xp) XP"
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.yellow)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(leaderLine)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white.opacity(0.04)
        )
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
        )
    }
}

// MARK: - Row

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let scope: LeaderboardScope
    let isCurrentUser: Bool

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    private var metric: String {
        switch scope {
        case .minutes: 
            return isRussian ? "\(entry.minutes) мин" : "\(entry.minutes) min"
        case .streak:  
            return "\(entry.streak) 🔥"
        case .xp:      
            return "\(entry.xp) XP"
        }
    }

    private var medal: String? {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Rank Number or Medal
            Group {
                if let medal {
                    Text(medal)
                        .font(.system(size: 20))
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(width: 32, alignment: .center)

            // User Avatar representation
            ZStack {
                Circle()
                    .fill(isCurrentUser ? Color.mint.opacity(0.2) : Color.white.opacity(0.06))
                    .frame(width: 32, height: 32)
                
                Text(entry.name.prefix(1).uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(isCurrentUser ? .mint : .white.opacity(0.6))
            }

            Text(entry.name)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            
            if isCurrentUser {
                Text(isRussian ? "Вы" : "You")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.mint.opacity(0.18), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.mint.opacity(0.3), lineWidth: 1))
                    .foregroundStyle(.mint)
            }
            
            Spacer()
            
            Text(metric)
                .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(isCurrentUser ? .mint : .white.opacity(0.85))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            isCurrentUser ?
            AnyShapeStyle(Color.mint.opacity(0.05)) :
            AnyShapeStyle(Color.white.opacity(0.03))
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isCurrentUser ? Color.mint.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Achievements Popup Card Detail Sheet

private struct AchievementDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Glowing background aura
            VStack {
                Circle()
                    .fill(LinearGradient(colors: achievement.gradient, startPoint: .top, endPoint: .bottom).opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(y: -40)
                Spacer()
            }
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header Close Button
                HStack {
                    Spacer()
                    Button {
                        HapticsManager.shared.playLightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(8)
                            .background(Color.white.opacity(0.08), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                
                Spacer(minLength: 0)

                // Large Glowing Icon
                let imageName = achievement.id.replacingOccurrences(of: ".", with: "_")
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .saturation(isUnlocked ? 1.0 : 0.0)
                        .opacity(isUnlocked ? 1.0 : 0.35)
                        .shadow(color: isUnlocked ? achievement.gradient.first?.opacity(0.5) ?? .clear : .clear, radius: 20)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: achievement.gradient.map { $0.opacity(isUnlocked ? 0.25 : 0.04) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: isUnlocked ? achievement.gradient.first?.opacity(0.4) ?? .clear : .clear, radius: 24)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: achievement.gradient.map { $0.opacity(isUnlocked ? 0.5 : 0.12) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: achievement.icon)
                            .font(.system(size: 46, weight: .bold))
                            .foregroundStyle(
                                isUnlocked ?
                                AnyShapeStyle(LinearGradient(colors: achievement.gradient, startPoint: .top, endPoint: .bottom)) :
                                AnyShapeStyle(LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                            )
                    }
                }

                // Info text
                VStack(spacing: 8) {
                    Text(isUnlocked ? (isRussian ? "ДОСТИЖЕНИЕ РАЗБЛОКИРОВАНО" : "ACHIEVEMENT UNLOCKED") : (isRussian ? "ДОСТИЖЕНИЕ ЗАБЛОКИРОВАНО" : "ACHIEVEMENT LOCKED"))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(isUnlocked ? achievement.gradient.first ?? .yellow : .white.opacity(0.3))
                        .tracking(1.5)

                    Text(achievement.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 4)

                    Text(achievement.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                }

                Spacer(minLength: 0)

                // Share link or lock status button
                if isUnlocked {
                    // Custom Share Button opening the Share Card Sheet
                    NavigationLink {
                        AchievementShareSheet(achievementKey: achievement.id)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .bold))
                            Text(isRussian ? "Поделиться Достижением" : "Share Achievement")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: achievement.gradient, startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(color: achievement.gradient.first?.opacity(0.4) ?? .clear, radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                        Text(isRussian ? "Продолжайте практику для открытия" : "Keep practicing to unlock")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2))
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 12)
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

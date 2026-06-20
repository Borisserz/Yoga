internal import SwiftUI

/// Identifiable wrapper so an achievement key can drive `.sheet(item:)`.
private struct ShareableAchievement: Identifiable {
    let id: String
}

struct MoreTabView: View {
    @Environment(AppState.self) private var app
    @State private var shareAchievement: ShareableAchievement?
    @State private var animateBackground = false
    @State private var showEditProfile = false
    @State private var pulseAvatar = false
    @State private var showStreakDetail = false
    @State private var showAIDetail = false
    @State private var showMinutesDetail = false
    @State private var currentAchievementIndex = 0
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }

    init() {}

    var body: some View {
        @Bindable var app = app
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(animate: $animateBackground)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // --- PREMIUM PROFILE CARD ---
                        VStack(spacing: 16) {
                            HStack(spacing: 18) {
                                // Pulsing Avatar with Glowing Ring
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.mint.opacity(0.2), .indigo.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 72, height: 72)
                                        .scaleEffect(pulseAvatar ? 1.08 : 0.98)
                                    
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(colors: [.mint, .teal, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 2
                                        )
                                        .frame(width: 72, height: 72)
                                    
                                    avatarView()
                                }
                                .shadow(color: .mint.opacity(0.35), radius: 10)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(app.displayName)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    
                                    // Plan Status Badge
                                    HStack(spacing: 5) {
                                        if app.isPremiumActivated {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 10))
                                                .foregroundStyle(.yellow)
                                            Text(isRussian ? "Премиум" : "Premium Plan")
                                                .font(.system(size: 10, weight: .black, design: .rounded))
                                                .foregroundStyle(.yellow)
                                        } else {
                                            Text(isRussian ? "Базовый уровень" : "Free Plan")
                                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.6))
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        app.isPremiumActivated ? Color.yellow.opacity(0.12) : Color.white.opacity(0.06),
                                        in: Capsule()
                                    )
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(app.isPremiumActivated ? Color.yellow.opacity(0.25) : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                
                                Spacer()
                                
                                Button {
                                    HapticsManager.shared.playLightImpact()
                                    showEditProfile = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 11, weight: .bold))
                                        Text(isRussian ? "Изм." : "Edit")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                    }
                                    .foregroundStyle(.mint)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Color.mint.opacity(0.08), in: Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(Color.mint.opacity(0.25), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.tactile)
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                        )
                        .card3DTilt(maxTilt: 6.0, cornerRadius: 28.0)
                        
                        // --- WEEKLY STREAK & CONSISTENCY CARD ---
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isRussian ? "АКТИВНОСТЬ НА ЭТОЙ НЕДЕЛЕ" : "WEEKLY CONSISTENCY")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .tracking(1.5)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.orange)
                                            .shadow(color: .orange.opacity(0.3), radius: 5)
                                        Text(isRussian ? "Серия: \(app.streakDays) дн." : "\(app.streakDays) Day Streak")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                    }
                                }
                                Spacer()
                                
                                Text(L("%lld / %lld days", app.sessionsThisWeek, app.weeklyTargetDays))
                                    .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.mint)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.mint.opacity(0.08), in: Capsule())
                            }
                            
                            // Weekly Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: max(8, geo.size.width * CGFloat(app.weeklyGoalProgress)), height: 8)
                                        .shadow(color: .mint.opacity(0.4), radius: 4)
                                }
                            }
                            .frame(height: 8)
                            
                            // Visual Activity Calendar representation
                            HStack(spacing: 8) {
                                let activity = app.weeklyActivity
                                ForEach(activity, id: \.label) { day in
                                    VStack(spacing: 6) {
                                        Text(day.label)
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.4))
                                        
                                        ZStack {
                                            Circle()
                                                .fill(day.minutes > 0 ? Color.mint.opacity(0.15) : Color.white.opacity(0.03))
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Circle().strokeBorder(day.minutes > 0 ? Color.mint.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                                                )
                                            
                                            if day.minutes > 0 {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .black))
                                                    .foregroundStyle(.mint)
                                            } else {
                                                Circle()
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(width: 4, height: 4)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            HapticsManager.shared.playLightImpact()
                            showStreakDetail = true
                        }
                        
                        // --- REDESIGNED STATS 2X2 DASHBOARD GRID ---
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            
                            // Level Stat Card
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isRussian ? "Уровень" : "Level Progress")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                HStack(spacing: 8) {
                                    LevelRing(level: app.level, progress: app.levelProgress)
                                        .frame(width: 36, height: 36)
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(L("Lvl %lld", app.level))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Text(L("xp.total", app.totalXP))
                                            .font(.system(size: 9, weight: .medium).monospacedDigit())
                                            .foregroundStyle(.white.opacity(0.4))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.85)
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                            
                            // Total Practice Minutes Card
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isRussian ? "Практика" : "Total Practice")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.indigo.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.indigo)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(isRussian ? "\(app.completedMinutes) мин" : "\(app.completedMinutes) min")
                                            .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Text(isRussian ? "Всего в потоке" : "Time in flow")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticsManager.shared.playLightImpact()
                                showMinutesDetail = true
                            }
                            
                            // Last AI Score Card
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isRussian ? "Оценка ИИ" : "Last AI Accuracy")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.mint.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "camera.viewfinder")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.mint)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        if app.lastSessionScore > 0 {
                                            Text(L("score.percent", app.lastSessionScore))
                                                .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                                                .foregroundStyle(.mint)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        } else {
                                            Text("—")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                        Text(isRussian ? "Качество асан" : "Technique score")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticsManager.shared.playLightImpact()
                                showAIDetail = true
                            }
                            
                            // Daily Streaks Card
                            VStack(alignment: .leading, spacing: 8) {
                                Text(isRussian ? "Серия дней" : "Consistency")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.5))
                                
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.orange.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.orange)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(L("%lld days", app.streakDays))
                                            .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        Text(isRussian ? "Регулярность" : "Current streak")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.4))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                HapticsManager.shared.playLightImpact()
                                showStreakDetail = true
                            }
                        }
                        .card3DTilt(maxTilt: 6.0, cornerRadius: 18.0)
                        
                        // --- LEADERBOARD & COMMUNITY ROW ---
                        NavigationLink {
                            LeaderboardView()
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.12))
                                        .frame(width: 46, height: 46)
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.yellow)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(isRussian ? "Лига и испытания" : "Leaderboard & Challenges")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text(isRussian ? "Соревнуйтесь с другими йогами" : "Compete with yogis worldwide")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // --- PREMIUM ACHIEVEMENTS CAROUSEL ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text(isRussian ? "Ваши достижения" : "Achievements")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 0) {
                                TabView(selection: $currentAchievementIndex) {
                                    ForEach(0..<AchievementDefinition.allAchievements.count, id: \.self) { index in
                                        let achievement = AchievementDefinition.allAchievements[index]
                                        let isUnlocked = app.earnedAchievements.contains(achievement.id)
                                        
                                        AchievementCarouselCard(
                                            achievement: achievement,
                                            isUnlocked: isUnlocked,
                                            isRussian: isRussian,
                                            onShare: {
                                                HapticsManager.shared.playLightImpact()
                                                shareAchievement = ShareableAchievement(id: achievement.id)
                                            }
                                        )
                                        .padding(.horizontal, 8)
                                        .scaleEffect(currentAchievementIndex == index ? 1.0 : 0.92)
                                        .opacity(currentAchievementIndex == index ? 1.0 : 0.5)
                                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentAchievementIndex)
                                        .tag(index)
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .frame(height: 250)
                                
                                // Custom Pagination Dots
                                HStack(spacing: 6) {
                                    ForEach(0..<AchievementDefinition.allAchievements.count, id: \.self) { index in
                                        let isActive = (currentAchievementIndex == index)
                                        Capsule()
                                            .fill(isActive ? Color.mint : Color.white.opacity(0.2))
                                            .frame(width: isActive ? 16 : 6, height: 6)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentAchievementIndex)
                                    }
                                }
                                .padding(.top, 6)
                                .padding(.bottom, 8)
                            }
                        }
                        
                        // --- SYSTEM SETTINGS CARD ---
                        VStack(alignment: .leading, spacing: 0) {
                            NavigationLink {
                                NotificationSettingsView()
                            } label: {
                                SettingsRow(icon: "bell.fill", color: .mint, title: isRussian ? "Уведомления" : "Notifications")
                            }
                            .buttonStyle(.plain)
                            
                            Divider().background(Color.white.opacity(0.06))
                            
                            NavigationLink {
                                HealthSettingsView()
                            } label: {
                                SettingsRow(icon: "heart.text.square.fill", color: .pink, title: isRussian ? "Здоровье Apple Health" : "Apple Health")
                            }
                            .buttonStyle(.plain)
                        }
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                        )
                        
                        // --- SUPPORT & LEGAL CARD ---
                        VStack(alignment: .leading, spacing: 0) {
                            Link(destination: URL(string: "https://example.com/support")!) {
                                InfoRow(icon: "questionmark.circle.fill", title: isRussian ? "Поддержка" : "Support")
                            }
                            Divider().background(Color.white.opacity(0.06))
                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                InfoRow(icon: "lock.fill", title: isRussian ? "Политика конфиденциальности" : "Privacy Policy")
                            }
                        }
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1.2)
                        )
                        
                        // --- RESET / SIGN OUT BUTTON ---
                        Button(role: .destructive) {
                            HapticsManager.shared.playWarning()
                            app.reset()
                        } label: {
                            Text(isRussian ? "Сбросить прогресс" : "Sign out & Reset")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.1), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.red.opacity(0.25), lineWidth: 1.2)
                                )
                        }
                        .buttonStyle(.tactile)
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .navigationTitle(isRussian ? "Профиль" : "Profile")
            .onAppear {
                animateBackground = true
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAvatar = true
                }
            }
        }
        .sheet(item: $shareAchievement) { item in
            AchievementShareSheet(achievementKey: item.id)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(app: app)
        }
        .sheet(isPresented: $showStreakDetail) {
            StreakDetailView()
        }
        .sheet(isPresented: $showAIDetail) {
            AIDetailView()
        }
        .sheet(isPresented: $showMinutesDetail) {
            MinutesStatsDetailView()
        }
    }
    
    @ViewBuilder
    private func avatarView() -> some View {
        if let avatarData = app.avatarData, let uiImage = UIImage(data: avatarData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 68, height: 68)
                .clipShape(Circle())
        } else {
            let preset = avatarPresets[safe: app.avatarPresetIndex] ?? avatarPresets[0]
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: preset.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 68, height: 68)
                Image(systemName: preset.iconName)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.65))
            }
            
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "arrow.up.right.square.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}

// MARK: - Carousel Card Subview
private struct AchievementCarouselCard: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool
    let isRussian: Bool
    let onShare: () -> Void

    private var fillGradientColors: [Color] {
        if isUnlocked {
            return achievement.gradient.map { $0.opacity(0.08) }
        } else {
            return [.clear]
        }
    }

    private var strokeGradientColors: [Color] {
        if isUnlocked {
            return achievement.gradient.map { $0.opacity(0.3) }
        } else {
            return [Color.white.opacity(0.08), Color.white.opacity(0.02)]
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Achievement Image with glowing border
            ZStack {
                let imageName = achievement.id.replacingOccurrences(of: ".", with: "_")
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .saturation(isUnlocked ? 1.0 : 0.0)
                        .opacity(isUnlocked ? 1.0 : 0.3)
                        .shadow(color: isUnlocked ? achievement.gradient.first?.opacity(0.4) ?? .clear : .clear, radius: 10)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 80, height: 80)
                    Image(systemName: achievement.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(isUnlocked ? LinearGradient(colors: achievement.gradient, startPoint: .top, endPoint: .bottom) : LinearGradient(colors: [.white.opacity(0.25)], startPoint: .top, endPoint: .bottom))
                }
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(8)
                        .background(Color.black.opacity(0.6), in: Circle())
                        .offset(x: 25, y: 25)
                }
            }
            .padding(.top, 14)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                
                Text(achievement.description)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(isUnlocked ? 0.6 : 0.35))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)
            }
            .padding(.horizontal, 12)
            
            Spacer(minLength: 0)
            
            // Bottom Action
            if isUnlocked {
                Button(action: onShare) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 10, weight: .bold))
                        Text(isRussian ? "Поделиться" : "Share")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.mint, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.bottom, 14)
            } else {
                Text(isRussian ? "Заблокировано" : "Locked")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.04), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.bottom, 14)
            }
        }
        .frame(width: 200, height: 230)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(colors: fillGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    LinearGradient(
                        colors: strokeGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: isUnlocked ? achievement.gradient.first?.opacity(0.15) ?? .clear : .clear, radius: 12, y: 6)
    }
}


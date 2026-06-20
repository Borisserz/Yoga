internal import SwiftUI
import PhotosUI

struct AvatarPreset: Identifiable, Hashable {
    let id: Int
    let iconName: String
    let gradient: [Color]
}

let avatarPresets = [
    AvatarPreset(id: 0, iconName: "figure.yoga", gradient: [.mint, .teal]),
    AvatarPreset(id: 1, iconName: "sparkles", gradient: [.orange, .pink]),
    AvatarPreset(id: 2, iconName: "leaf.fill", gradient: [.green, .mint]),
    AvatarPreset(id: 3, iconName: "bolt.fill", gradient: [.purple, .blue]),
    AvatarPreset(id: 4, iconName: "heart.fill", gradient: [.red, .pink]),
    AvatarPreset(id: 5, iconName: "moon.stars.fill", gradient: [.indigo, .purple]),
]

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    let app: AppState
    
    @State private var profileName: String
    @State private var selectedPresetIndex: Int
    @State private var selectedPhotoData: Data?
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    private var isRussian: Bool {
        Locale.current.language.languageCode?.identifier == "ru"
    }
    
    init(app: AppState) {
        self.app = app
        _profileName = State(initialValue: app.displayName)
        _selectedPresetIndex = State(initialValue: app.avatarPresetIndex)
        _selectedPhotoData = State(initialValue: app.avatarData)
    }
    
    var body: some View {
        ZStack {
            // Dark base background
            Color.black.ignoresSafeArea()
            
            // Subtle glowing blobs
            VStack {
                Circle()
                    .fill(Color.mint.opacity(0.12))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -80, y: -40)
                Spacer()
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // --- HEADER ---
                    HStack {
                        Text(isRussian ? "Редактировать профиль" : "Edit Profile")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(10)
                                .background(Color.white.opacity(0.06), in: Circle())
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 16)
                    
                    // --- AVATAR PREVIEW ---
                    VStack(spacing: 16) {
                        ZStack {
                            // Glowing rings
                            Circle()
                                .stroke(Color.white.opacity(0.04), lineWidth: 8)
                                .frame(width: 140, height: 140)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: selectedPhotoData != nil ? [.mint, .teal] : (avatarPresets[safe: selectedPresetIndex]?.gradient ?? [.mint, .teal]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 130, height: 130)
                                .shadow(color: .mint.opacity(0.2), radius: 8)
                            
                            // Image / Preset Icon
                            ZStack {
                                if let selectedPhotoData, let uiImage = UIImage(data: selectedPhotoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    let preset = avatarPresets[safe: selectedPresetIndex] ?? avatarPresets[0]
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: preset.gradient,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: preset.iconName)
                                        .font(.system(size: 48))
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            // Camera Edit Overlay Badge
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                ZStack {
                                    Circle()
                                        .fill(Color.mint)
                                        .frame(width: 38, height: 38)
                                        .shadow(color: .black.opacity(0.35), radius: 4)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                            }
                            .buttonStyle(.plain)
                            .offset(x: 44, y: 44)
                        }
                        
                        if selectedPhotoData != nil {
                            // Button to clear custom photo and return to preset
                            Button {
                                HapticsManager.shared.playLightImpact()
                                selectedPhotoData = nil
                                selectedPhotoItem = nil
                            } label: {
                                Text(isRussian ? "Удалить фото" : "Remove Photo")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.red.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.red.opacity(0.18), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // --- PRESET AVATARS SELECTOR ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isRussian ? "Выберите аватар" : "Choose Avatar Preset")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 4)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(avatarPresets) { preset in
                                    let isSelected = (selectedPresetIndex == preset.id && selectedPhotoData == nil)
                                    
                                    Button {
                                        HapticsManager.shared.playLightImpact()
                                        selectedPhotoData = nil // clear photo if they select a preset
                                        selectedPresetIndex = preset.id
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: preset.gradient,
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 54, height: 54)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(Color.white.opacity(isSelected ? 0.8 : 0.0), lineWidth: 2.5)
                                                )
                                                .shadow(color: preset.gradient.first?.opacity(isSelected ? 0.45 : 0.0) ?? .clear, radius: 8)
                                            
                                            Image(systemName: preset.iconName)
                                                .font(.system(size: 22))
                                                .foregroundStyle(.white)
                                            
                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(.white)
                                                    .offset(x: 18, y: -18)
                                            }
                                        }
                                        .scaleEffect(isSelected ? 1.08 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // --- NAME INPUT FIELD ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text(isRussian ? "Имя профиля" : "Profile Name")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 4)
                        
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 24)
                            
                            TextField(isRussian ? "Введите ваше имя" : "Enter your name", text: $profileName)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                            
                            if !profileName.isEmpty {
                                Button {
                                    profileName = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    
                    // --- ACTION BUTTONS ---
                    VStack(spacing: 12) {
                        Button {
                            HapticsManager.shared.playSuccess()
                            app.updateProfile(
                                name: profileName,
                                avatarData: selectedPhotoData,
                                avatarPresetIndex: selectedPresetIndex
                            )
                            dismiss()
                        } label: {
                            Text(isRussian ? "Сохранить изменения" : "Save Changes")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(colors: [.mint, .teal], startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(Capsule())
                                .shadow(color: .mint.opacity(0.35), radius: 8, y: 3)
                        }
                        .buttonStyle(.tactile)
                        .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                        
                        Button {
                            HapticsManager.shared.playLightImpact()
                            dismiss()
                        } label: {
                            Text(isRussian ? "Отмена" : "Cancel")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.white.opacity(0.04), in: Capsule())
                                .overlay(
                                    Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        selectedPhotoData = data
                    }
                }
            }
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

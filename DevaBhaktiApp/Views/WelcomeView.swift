import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void
    @Environment(LocalizationService.self) private var loc
    @State private var appeared = false
    @State private var omRotation: Double = 0
    @State private var particlePhase: Bool = false
    @State private var showLanguagePicker = false

    var body: some View {
        ZStack {
            backgroundGradient

            floatingParticles

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        showLanguagePicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(loc.currentLanguage.flag)
                                .font(.system(size: 18))
                            Image(systemName: "globe")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.4))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                }

                Spacer()

                omSymbol
                    .padding(.bottom, 32)

                titleSection
                    .padding(.bottom, 40)

                philosophyCard
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)

                continueButton
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: 60)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { appeared = true }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                omRotation = 360
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                particlePhase = true
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerSheet()
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.06, green: 0.04, blue: 0.12), location: 0),
                .init(color: Color(red: 0.12, green: 0.08, blue: 0.22), location: 0.4),
                .init(color: Color(red: 0.18, green: 0.10, blue: 0.28), location: 0.7),
                .init(color: Color(red: 0.10, green: 0.06, blue: 0.18), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var floatingParticles: some View {
        Canvas { context, size in
            for i in 0..<30 {
                let seed = Double(i) * 137.508
                let x = (sin(seed) * 0.5 + 0.5) * size.width
                let baseY = (cos(seed * 0.7) * 0.5 + 0.5) * size.height
                let y = baseY + (particlePhase ? -20 : 20) * sin(seed * 0.3)
                let radius = 1.0 + sin(seed * 0.5) * 1.5
                let opacity = 0.15 + sin(seed * 0.3) * 0.15

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                    with: .color(.yellow.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private var omSymbol: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [.yellow.opacity(0.3), .orange.opacity(0.5), .yellow.opacity(0.3)],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(omRotation))

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [.orange.opacity(0.2), .yellow.opacity(0.4), .orange.opacity(0.2)],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-omRotation * 0.7))

            Text("ॐ")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.85, blue: 0.4), Color(red: 0.9, green: 0.7, blue: 0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .orange.opacity(0.6), radius: 20)
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.5)
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text(loc.t(.devaBhakti))
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(loc.t(.divineDevtoion))
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(4)
                .textCase(.uppercase)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private var philosophyCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, Color(red: 0.85, green: 0.65, blue: 0.2)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 40, height: 1)
                Text(loc.t(.ishtaDevata))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                    .tracking(2)
                Rectangle()
                    .fill(LinearGradient(colors: [Color(red: 0.85, green: 0.65, blue: 0.2), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 40, height: 1)
            }

            Text(loc.t(.welcomePhilosophy))
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.4), .clear, Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 40)
    }

    private var continueButton: some View {
        Button(action: onContinue) {
            HStack(spacing: 12) {
                Text(loc.t(.chooseYourDeity))
                    .font(.system(size: 17, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color(red: 0.08, green: 0.05, blue: 0.15))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(red: 1, green: 0.9, blue: 0.5), Color(red: 0.85, green: 0.65, blue: 0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 28))
            .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.4), radius: 16, y: 8)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
}

struct LanguagePickerSheet: View {
    @Environment(LocalizationService.self) private var loc
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(loc.t(.language))
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(.primary)
                .padding(.top, 8)

            VStack(spacing: 8) {
                ForEach(AppLanguage.allCases, id: \.rawValue) { language in
                    Button {
                        loc.currentLanguage = language
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            Text(language.flag)
                                .font(.system(size: 28))
                            Text(language.displayName)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.primary)
                            Spacer()
                            if loc.currentLanguage == language {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color(red: 0.85, green: 0.65, blue: 0.2))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(loc.currentLanguage == language ? Color(red: 0.85, green: 0.65, blue: 0.2).opacity(0.1) : Color(.secondarySystemGroupedBackground))
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

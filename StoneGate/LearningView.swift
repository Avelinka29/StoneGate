import SwiftUI

struct LearningView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedCourse: LearningCourse? = nil {
        didSet {
            if let course = selectedCourse {
                UserDefaults.standard.set(course.rawValue, forKey: "selectedLearningCourse")
            }
        }
    }

    private var theme: Theme { Theme() }

    init() {
        // Load saved course or default to adults for new users
        let savedCourseRaw = UserDefaults.standard.string(forKey: "selectedLearningCourse")
        if let savedCourseRaw = savedCourseRaw,
           let savedCourse = LearningCourse(rawValue: savedCourseRaw) {
            _selectedCourse = State(initialValue: savedCourse)
        } else {
            _selectedCourse = State(initialValue: .adults) // Default to adults for new users
        }
    }

    enum LearningCourse: String {
        case appUsage, kids, adults
    }

    var body: some View {
        ZStack {
            theme.primaryBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.primaryText)
                            .frame(width: 32, height: 32)
                    }

                    Spacer()

                    Text("Обучение StoneGate")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)

                    Spacer()

                    // Placeholder for symmetry
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 52)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Main Title
                        Text("Выберите направление обучения, которое подходит именно Вам")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        // Course Cards
                        VStack(spacing: 16) {
                            LearningCourseCard(
                                icon: "iphone",
                                title: "Как пользоваться приложением",
                                subtitle: "Пройдите урок по всем функциям StoneGate - от регистрации до профинвестиций инструментов",
                                isSelected: selectedCourse == .appUsage,
                                course: .appUsage,
                                isHighlighted: false,
                                onSelect: { course in
                                    selectedCourse = course
                                }
                            )

                            LearningCourseCard(
                                icon: "face.smiling",
                                title: "Для детей",
                                subtitle: "Интерактивное обучение финансовой грамотности в игровой форме для юных",
                                isSelected: selectedCourse == .kids,
                                course: .kids,
                                isHighlighted: false,
                                onSelect: { course in
                                    selectedCourse = course
                                }
                            )

                            LearningCourseCard(
                                icon: "graduationcap",
                                title: "Для взрослых",
                                subtitle: "Профессиональное обучение инвестированию, управлению капиталом и финансовыми инструментами",
                                isSelected: selectedCourse == .adults,
                                course: .adults,
                                isHighlighted: false,
                                onSelect: { course in
                                    selectedCourse = course
                                }
                            )
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 40)

                        // Start Button
                        Button(action: {
                            startLearning()
                        }) {
                            Text("Начать")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(theme.primaryBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accentColor)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 34)
                        .disabled(selectedCourse == nil)
                        .opacity(selectedCourse == nil ? 0.5 : 1.0)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func startLearning() {
        guard let course = selectedCourse else { return }

        print("Starting learning course: \(course)")
        // TODO: Navigate to actual learning content
        dismiss()
    }
}

private struct LearningCourseCard: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let course: LearningView.LearningCourse
    var isHighlighted: Bool = false
    var onSelect: ((LearningView.LearningCourse) -> Void)? = nil

    private var theme: Theme { Theme() }

    var body: some View {
        Button(action: {
            onSelect?(course)
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(theme.primaryText)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.primaryText)
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(theme.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(2)
                }

                Spacer()
            }
            .padding(20)
            .background(theme.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke((isSelected || isHighlighted) ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LearningView()
        .environmentObject(ThemeManager.shared)
}
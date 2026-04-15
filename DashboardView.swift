import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: RunningCoachViewModel
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    goalCard
                    statsCard
                    nextSessionCard
                    shareCardButton
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .sheet(isPresented: $showShareSheet) {
                if let image = shareImage {
                    ShareActivityView(activityItems: [image])
                }
            }
        }
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.trainingGoal.goalName)
                .font(.headline)
            Text(String(format: "Goal distance %.1f km", viewModel.trainingGoal.distanceKm))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(viewModel.targetPaceText)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Race date: \(viewModel.trainingGoal.targetDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last 7 days")
                .font(.headline)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Weekly distance")
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f km", viewModel.weeklyDistance))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Average pace")
                        .foregroundColor(.secondary)
                    Text(viewModel.averagePace > 0 ? String(format: "%.1f min/km", viewModel.averagePace) : "-")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var nextSessionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Next session")
                .font(.headline)
            if let session = viewModel.nextUpcomingSession {
                Text(session.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(session.date, style: .date)
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f km / %d min", session.distanceKm, session.durationMinutes))
                    .foregroundColor(.secondary)
            } else {
                Text("No upcoming sessions yet.")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private var shareCardButton: some View {
        Button(action: createShareCard) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Create share card")
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
    }

    private func createShareCard() {
        let paceText = viewModel.averagePace > 0 ? String(format: "%.1f min/km", viewModel.averagePace) : "-"
        let card = ShareCardView(
            title: "Sub-3 Training",
            subtitle: viewModel.trainingGoal.goalName,
            stats: String(format: "Weekly %.1f km\nAverage pace %@", viewModel.weeklyDistance, paceText),
            footer: viewModel.nextUpcomingSession?.title ?? "Ready for the next run"
        )

        if let image = card.snapshot() {
            shareImage = image
            showShareSheet = true
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(viewModel: RunningCoachViewModel())
    }
}

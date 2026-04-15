import SwiftUI

struct TrainingPlanView: View {
    @ObservedObject var viewModel: RunningCoachViewModel
    @State private var title = ""
    @State private var date = Date()
    @State private var distance = ""
    @State private var duration = ""
    @State private var description = ""
    @State private var goalName = "Sub3 Marathon"
    @State private var goalDate = Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add training session")) {
                        TextField("Session title", text: $title)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Distance (km)", text: $distance)
                            .keyboardType(.decimalPad)
                        TextField("Duration (min)", text: $duration)
                            .keyboardType(.numberPad)
                        TextField("Description", text: $description)
                    }

                    Button(action: addSession) {
                        Text("Save session")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Section(header: Text("Generate goal plan")) {
                        TextField("Goal name", text: $goalName)
                        DatePicker("Goal date", selection: $goalDate, displayedComponents: .date)
                        Button(action: generateGoalPlan) {
                            Text("Generate sub-3 plan")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        Text("Current goal: \(viewModel.trainingGoal.goalName) \(String(format: "%.1f km", viewModel.trainingGoal.distanceKm))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if !viewModel.generatedPlan.isEmpty {
                    List {
                        Section(header: Text("Generated plan")) {
                            ForEach(viewModel.generatedPlan) { session in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(session.title)
                                            .font(.headline)
                                        if let type = session.type {
                                            Text(type)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                                .padding(4)
                                                .background(Color(.systemGray5))
                                                .cornerRadius(6)
                                        }
                                    }
                                    Text(session.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.1f km / %d min", session.distanceKm, session.durationMinutes))
                                        .font(.subheadline)
                                    Text(session.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }

                List(viewModel.sessions) { session in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(session.title)
                                .font(.headline)
                            if let type = session.type {
                                Text(type)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(session.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f km / %d min", session.distanceKm, session.durationMinutes))
                            .font(.subheadline)
                        Text(session.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Training Plan")
        }
    }

    private func addSession() {
        guard let distanceKm = Double(distance), let durationMinutes = Int(duration), !title.isEmpty else {
            return
        }
        viewModel.addSession(
            title: title,
            date: date,
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
            description: description
        )
        title = ""
        distance = ""
        duration = ""
        description = ""
    }

    private func generateGoalPlan() {
        viewModel.trainingGoal.goalName = goalName
        viewModel.trainingGoal.targetDate = goalDate
        viewModel.generateGoalPlan()
    }
}

struct TrainingPlanView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingPlanView(viewModel: RunningCoachViewModel())
    }
}

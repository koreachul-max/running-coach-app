import SwiftUI

struct RunLogView: View {
    @ObservedObject var viewModel: RunningCoachViewModel
    @State private var date = Date()
    @State private var distance = ""
    @State private var duration = ""
    @State private var notes = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add run log")) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Distance (km)", text: $distance)
                            .keyboardType(.decimalPad)
                        TextField("Duration (min)", text: $duration)
                            .keyboardType(.numberPad)
                        TextField("Notes", text: $notes)
                    }

                    Button(action: addLog) {
                        Text("Save log")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                List(viewModel.runLogs) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(log.date, style: .date)
                            .font(.headline)
                        Text(String(format: "%.1f km / %d min", log.distanceKm, log.durationMinutes))
                            .font(.subheadline)
                        Text(String(format: "Average pace %.1f min/km", log.averagePace))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(log.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Run Logs")
        }
    }

    private func addLog() {
        guard let distanceKm = Double(distance), let durationMinutes = Int(duration) else {
            return
        }
        viewModel.addRunLog(date: date, distanceKm: distanceKm, durationMinutes: durationMinutes, notes: notes)
        distance = ""
        duration = ""
        notes = ""
    }
}

struct RunLogView_Previews: PreviewProvider {
    static var previews: some View {
        RunLogView(viewModel: RunningCoachViewModel())
    }
}

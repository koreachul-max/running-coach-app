import SwiftUI
import CoreLocation

class RunningCoachViewModel: ObservableObject {
    @Published var sessions: [TrainingSession] = [] { didSet { saveSessions() } }
    @Published var runLogs: [RunLog] = [] { didSet { saveRunLogs() } }
    @Published var mediaItems: [MediaItem] = []
    @Published var routes: [RunRoute] = [] { didSet { saveRoutes() } }
    @Published var generatedPlan: [TrainingSession] = []
    @Published var trainingGoal = TrainingGoal(
        goalName: "Sub3 Marathon",
        distanceKm: 42.195,
        targetDate: Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()
    ) { didSet { saveGoal() } }

    private let sessionsFile = "sessions.json"
    private let runLogsFile = "runlogs.json"
    private let routesFile = "routes.json"
    private let goalFile = "goal.json"
    private let targetPaceSecondsPerKm = 4 * 60 + 15

    var targetPaceText: String {
        String(format: "%d'%.2d\" / km", targetPaceSecondsPerKm / 60, targetPaceSecondsPerKm % 60)
    }

    var weeklyDistance: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return runLogs.filter { $0.date >= weekAgo }.reduce(0) { $0 + $1.distanceKm }
    }

    var averagePace: Double {
        let validLogs = runLogs.filter { $0.distanceKm > 0 }
        guard !validLogs.isEmpty else { return 0 }
        let totalPace = validLogs.reduce(0) { $0 + $1.averagePace }
        return totalPace / Double(validLogs.count)
    }

    var nextUpcomingSession: TrainingSession? {
        sessions
            .filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
            .sorted { $0.date < $1.date }
            .first
    }

    init() {
        loadSessions()
        loadRunLogs()
        loadRoutes()
        loadGoal()

        if sessions.isEmpty {
            sessions = [
                TrainingSession(
                    title: "Easy Recovery",
                    date: Date(),
                    distanceKm: 10,
                    durationMinutes: 60,
                    description: "Comfortable aerobic recovery run.",
                    type: "Easy"
                )
            ]
        }

        if runLogs.isEmpty {
            runLogs = [
                RunLog(
                    date: Date(),
                    distanceKm: 5,
                    durationMinutes: 27,
                    notes: "Steady effort with a strong final kilometer."
                )
            ]
        }
    }

    func addSession(title: String, date: Date, distanceKm: Double, durationMinutes: Int, description: String, type: String? = nil) {
        let session = TrainingSession(
            title: title,
            date: date,
            distanceKm: distanceKm,
            durationMinutes: durationMinutes,
            description: description,
            type: type
        )
        sessions.append(session)
    }

    func addRunLog(date: Date, distanceKm: Double, durationMinutes: Int, notes: String) {
        let log = RunLog(date: date, distanceKm: distanceKm, durationMinutes: durationMinutes, notes: notes)
        runLogs.append(log)
    }

    func addMedia(image: UIImage?, videoURL: URL?, caption: String) {
        let item = MediaItem(image: image, videoURL: videoURL, caption: caption)
        mediaItems.append(item)
    }

    func addRoute(name: String, points: [RoutePoint], durationMinutes: Int) {
        let route = RunRoute(
            name: name,
            date: Date(),
            points: points,
            durationMinutes: durationMinutes,
            distanceKm: calculateRouteDistance(points: points)
        )
        routes.append(route)
    }

    func generateGoalPlan() {
        saveGoal()
        generatedPlan = createSub3TrainingPlan()
    }

    private func createSub3TrainingPlan() -> [TrainingSession] {
        var plan: [TrainingSession] = []
        let calendar = Calendar.current
        let nextMonday = calendar.nextDate(
            after: Date(),
            matching: DateComponents(weekday: 2),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? Date()

        let targetDate = trainingGoal.targetDate
        let paceEasy = 5 * 60 + 20
        let paceTempo = 4 * 60 + 20
        let paceInterval = 4 * 60 + 10
        let paceLong = 5 * 60 + 30
        let longRunDistances: [Double] = [18, 22, 25, 28]

        for index in 0..<4 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: index, to: nextMonday) ?? Date()
            let easyRunDate = weekStart
            let intervalDate = calendar.date(byAdding: .day, value: 2, to: weekStart) ?? Date()
            let tempoDate = calendar.date(byAdding: .day, value: 4, to: weekStart) ?? Date()
            let longRunDate = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? Date()

            plan.append(TrainingSession(
                title: "Easy Run",
                date: easyRunDate,
                distanceKm: 10,
                durationMinutes: minutes(for: 10, paceSeconds: paceEasy),
                description: "Controlled aerobic run for recovery and mileage.",
                type: "Easy"
            ))

            plan.append(TrainingSession(
                title: "Interval",
                date: intervalDate,
                distanceKm: 8,
                durationMinutes: minutes(for: 8, paceSeconds: paceInterval),
                description: "Five repeats of 800m at faster-than-goal pace.",
                type: "Interval"
            ))

            plan.append(TrainingSession(
                title: "Tempo Run",
                date: tempoDate,
                distanceKm: 12,
                durationMinutes: minutes(for: 12, paceSeconds: paceTempo),
                description: "Sustained tempo effort around marathon pace.",
                type: "Tempo"
            ))

            plan.append(TrainingSession(
                title: "Long Run",
                date: longRunDate,
                distanceKm: longRunDistances[index],
                durationMinutes: minutes(for: longRunDistances[index], paceSeconds: paceLong),
                description: "Long aerobic run to build endurance for a sub-3 marathon.",
                type: "Long"
            ))

            if index == 3 {
                plan.append(TrainingSession(
                    title: "Race Prep",
                    date: calendar.date(byAdding: .day, value: 1, to: longRunDate) ?? Date(),
                    distanceKm: 5,
                    durationMinutes: minutes(for: 5, paceSeconds: paceEasy),
                    description: "Short recovery run to stay fresh before race day.",
                    type: "Recovery"
                ))
            }
        }

        if targetDate > nextMonday {
            plan.append(TrainingSession(
                title: "Goal Race",
                date: targetDate,
                distanceKm: trainingGoal.distanceKm,
                durationMinutes: minutes(for: trainingGoal.distanceKm, paceSeconds: targetPaceSecondsPerKm),
                description: "Target marathon effort for your sub-3 attempt.",
                type: "Race"
            ))
        }

        return plan
    }

    private func minutes(for distance: Double, paceSeconds: Int) -> Int {
        Int(round(distance * Double(paceSeconds) / 60.0))
    }

    private func calculateRouteDistance(points: [RoutePoint]) -> Double {
        guard points.count > 1 else { return 0 }
        var total: Double = 0
        for pair in zip(points, points.dropFirst()) {
            let start = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
            let end = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
            total += end.distance(from: start)
        }
        return total / 1000.0
    }

    private func saveSessions() {
        save(sessions, to: sessionsFile)
    }

    private func saveRunLogs() {
        save(runLogs, to: runLogsFile)
    }

    private func saveRoutes() {
        save(routes, to: routesFile)
    }

    private func saveGoal() {
        save(trainingGoal, to: goalFile)
    }

    private func loadSessions() {
        if let loaded: [TrainingSession] = load(from: sessionsFile) {
            sessions = loaded
        }
    }

    private func loadRunLogs() {
        if let loaded: [RunLog] = load(from: runLogsFile) {
            runLogs = loaded
        }
    }

    private func loadRoutes() {
        if let loaded: [RunRoute] = load(from: routesFile) {
            routes = loaded
        }
    }

    private func loadGoal() {
        if let loaded: TrainingGoal = load(from: goalFile) {
            trainingGoal = loaded
        }
    }

    private func save<T: Codable>(_ value: T, to filename: String) {
        let url = documentsDirectory().appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: [.atomicWrite])
        } catch {
            print("Save error: \(error)")
        }
    }

    private func load<T: Codable>(from filename: String) -> T? {
        let url = documentsDirectory().appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Load error: \(error)")
            return nil
        }
    }

    private func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

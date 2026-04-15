import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RunningCoachViewModel()

    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }

            TrainingPlanView(viewModel: viewModel)
                .tabItem {
                    Label("Plan", systemImage: "list.bullet.rectangle")
                }

            RunLogView(viewModel: viewModel)
                .tabItem {
                    Label("Logs", systemImage: "figure.run")
                }

            RouteMapView(viewModel: viewModel)
                .tabItem {
                    Label("Routes", systemImage: "map")
                }

            MediaGalleryView(viewModel: viewModel)
                .tabItem {
                    Label("Media", systemImage: "photo.on.rectangle")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

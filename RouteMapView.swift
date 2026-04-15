import SwiftUI
import MapKit
import CoreLocation

struct RouteMapView: View {
    @ObservedObject var viewModel: RunningCoachViewModel
    @StateObject private var tracker = LocationTracker()
    @State private var routeName = "Morning Route"
    @State private var selectedRoute: RunRoute?
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                RouteMapRepresentable(
                    routePoints: tracker.routePoints,
                    selectedRoute: selectedRoute,
                    userLocation: tracker.lastLocation
                )
                .frame(height: 320)
                .cornerRadius(16)
                .padding(.horizontal)

                VStack(spacing: 12) {
                    HStack {
                        Text(tracker.isTracking ? "Tracking" : "Ready")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f km", tracker.distanceKm))
                            .font(.headline)
                        Text("/")
                        Text(String(format: "%d min", tracker.elapsedSeconds / 60))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    TextField("Route name", text: $routeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        Button(action: toggleTracking) {
                            Text(tracker.isTracking ? "Stop tracking" : "Start tracking")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(tracker.isTracking ? Color.red : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: saveCurrentRoute) {
                            Text("Save route")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(tracker.routePoints.count < 2 || routeName.isEmpty)
                    }
                    .padding(.horizontal)
                }

                if !viewModel.routes.isEmpty {
                    List {
                        Section(header: Text("Saved routes")) {
                            ForEach(viewModel.routes) { route in
                                Button(action: {
                                    selectedRoute = route
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(route.name)
                                            .font(.headline)
                                        Text(route.summary)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(route.date, style: .date)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Routes")
            .alert("Location permission is required to record a route.", isPresented: $showPermissionAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func toggleTracking() {
        if tracker.isTracking {
            tracker.stopTracking()
        } else {
            let status = CLLocationManager.authorizationStatus()
            if status == .denied || status == .restricted {
                showPermissionAlert = true
            } else {
                tracker.requestAuthorization()
                tracker.startTracking()
            }
        }
    }

    private func saveCurrentRoute() {
        viewModel.addRoute(
            name: routeName,
            points: tracker.routePoints.map { RoutePoint(coordinate: $0) },
            durationMinutes: tracker.elapsedSeconds / 60
        )
        routeName = "Morning Route"
        tracker.stopTracking()
        selectedRoute = viewModel.routes.last
    }
}

final class LocationTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var routePoints: [CLLocationCoordinate2D] = []
    @Published var isTracking = false
    @Published var elapsedSeconds = 0
    @Published var lastLocation: CLLocation?

    private let manager = CLLocationManager()
    private var timer: Timer?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        routePoints.removeAll()
        elapsedSeconds = 0
        isTracking = true
        manager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
        isTracking = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        if isTracking {
            routePoints.append(location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    var distanceKm: Double {
        guard routePoints.count > 1 else { return 0 }
        var total: Double = 0
        for pair in zip(routePoints, routePoints.dropFirst()) {
            let start = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
            let end = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
            total += end.distance(from: start)
        }
        return total / 1000
    }
}

struct RouteMapRepresentable: UIViewRepresentable {
    var routePoints: [CLLocationCoordinate2D]
    var selectedRoute: RunRoute?
    var userLocation: CLLocation?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)

        let coordinates = selectedRoute?.coordinates ?? routePoints
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            uiView.addOverlay(polyline)
            uiView.setVisibleMapRect(
                polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 60, left: 60, bottom: 60, right: 60),
                animated: true
            )
        } else if let location = userLocation {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 1800,
                longitudinalMeters: 1800
            )
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemRed
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

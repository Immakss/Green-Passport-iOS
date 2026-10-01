import CoreLocation

final class CoreLocationRepository: LocationRepository {
    private static let timeout = Duration.seconds(5)

    func currentLocation() async -> GeoPoint? {
        let session = CLServiceSession(authorization: .whenInUse)
        defer {
            session.invalidate()
        }
        return await withTaskGroup(of: GeoPoint?.self) { group in
            group.addTask {
                return await Self.firstLocation()
            }
            group.addTask {
                try? await Task.sleep(for: Self.timeout)
                return nil
            }
            let location = await group.next() ?? nil
            group.cancelAll()
            return location
        }
    }

    private static func firstLocation() async -> GeoPoint? {
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                    return nil
                }
                if let location = update.location {
                    return GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}

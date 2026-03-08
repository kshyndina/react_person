import SwiftUI
import AVFoundation
import CoreLocation
import Contacts
import Photos
import EventKit
import CoreBluetooth
import CoreMotion
import HealthKit
import Speech
import UserNotifications
import LocalAuthentication
import MediaPlayer
import CoreNFC

// MARK: - Permission Manager

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    @Published var statuses: [String: String] = [:]

    private var locationManager: CLLocationManager?
    private var bluetoothManager: CBCentralManager?
    private let motionManager = CMMotionActivityManager()
    private let healthStore = HKHealthStore()

    func requestAll() {
        requestCamera()
        requestMicrophone()
        requestLocation()
        requestContacts()
        requestPhotos()
        requestCalendar()
        requestReminders()
        requestBluetooth()
        requestMotion()
        requestHealth()
        requestSpeech()
        requestNotifications()
        requestFaceID()
        requestMediaLibrary()
    }

    // MARK: Camera
    func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.statuses["Camera"] = granted ? "Granted" : "Denied"
            }
        }
    }

    // MARK: Microphone
    func requestMicrophone() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                self.statuses["Microphone"] = granted ? "Granted" : "Denied"
            }
        }
    }

    // MARK: Location (Always)
    func requestLocation() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            switch manager.authorizationStatus {
            case .authorizedAlways: self.statuses["Location"] = "Always"
            case .authorizedWhenInUse: self.statuses["Location"] = "When In Use"
            case .denied, .restricted: self.statuses["Location"] = "Denied"
            case .notDetermined: self.statuses["Location"] = "Not Asked"
            @unknown default: self.statuses["Location"] = "Unknown"
            }
        }
    }

    // MARK: Contacts
    func requestContacts() {
        CNContactStore().requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                self.statuses["Contacts"] = granted ? "Granted" : "Denied"
            }
        }
    }

    // MARK: Photos
    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: self.statuses["Photos"] = "Full Access"
                case .limited: self.statuses["Photos"] = "Limited"
                case .denied, .restricted: self.statuses["Photos"] = "Denied"
                default: self.statuses["Photos"] = "Unknown"
                }
            }
        }
    }

    // MARK: Calendar
    func requestCalendar() {
        let store = EKEventStore()
        if #available(iOS 17.0, *) {
            store.requestFullAccessToEvents { granted, _ in
                DispatchQueue.main.async {
                    self.statuses["Calendar"] = granted ? "Granted" : "Denied"
                }
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                DispatchQueue.main.async {
                    self.statuses["Calendar"] = granted ? "Granted" : "Denied"
                }
            }
        }
    }

    // MARK: Reminders
    func requestReminders() {
        let store = EKEventStore()
        if #available(iOS 17.0, *) {
            store.requestFullAccessToReminders { granted, _ in
                DispatchQueue.main.async {
                    self.statuses["Reminders"] = granted ? "Granted" : "Denied"
                }
            }
        } else {
            store.requestAccess(to: .reminder) { granted, _ in
                DispatchQueue.main.async {
                    self.statuses["Reminders"] = granted ? "Granted" : "Denied"
                }
            }
        }
    }

    // MARK: Bluetooth
    func requestBluetooth() {
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .poweredOn: self.statuses["Bluetooth"] = "Granted"
            case .unauthorized: self.statuses["Bluetooth"] = "Denied"
            default: self.statuses["Bluetooth"] = "Unavailable"
            }
        }
    }

    // MARK: Motion & Fitness
    func requestMotion() {
        motionManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { _, error in
            DispatchQueue.main.async {
                if let error = error as? CMError, error == CMError(.motionActivityNotAuthorized) {
                    self.statuses["Motion"] = "Denied"
                } else {
                    self.statuses["Motion"] = "Granted"
                }
            }
        }
    }

    // MARK: Health
    func requestHealth() {
        guard HKHealthStore.isHealthDataAvailable() else {
            statuses["Health"] = "Unavailable"
            return
        }
        let types: Set<HKSampleType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.bodyMass),
            HKQuantityType(.height),
            HKQuantityType(.bloodGlucose),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.bodyTemperature),
            HKCategoryType(.sleepAnalysis),
        ]
        healthStore.requestAuthorization(toShare: types, read: types) { granted, _ in
            DispatchQueue.main.async {
                self.statuses["Health"] = granted ? "Granted" : "Denied"
            }
        }
    }

    // MARK: Speech Recognition
    func requestSpeech() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: self.statuses["Speech"] = "Granted"
                case .denied, .restricted: self.statuses["Speech"] = "Denied"
                default: self.statuses["Speech"] = "Unknown"
                }
            }
        }
    }

    // MARK: Notifications
    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, _ in
            DispatchQueue.main.async {
                self.statuses["Notifications"] = granted ? "Granted" : "Denied"
            }
        }
    }

    // MARK: Face ID / Biometrics
    func requestFaceID() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate for app access") { success, _ in
                DispatchQueue.main.async {
                    self.statuses["Face ID"] = success ? "Granted" : "Denied"
                }
            }
        } else {
            statuses["Face ID"] = "Unavailable"
        }
    }

    // MARK: Media Library
    func requestMediaLibrary() {
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized: self.statuses["Media Library"] = "Granted"
                case .denied, .restricted: self.statuses["Media Library"] = "Denied"
                default: self.statuses["Media Library"] = "Unknown"
                }
            }
        }
    }
}

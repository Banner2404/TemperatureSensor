//
//  TemperatureManager.swift
//  TemperatureSensor
//
//  Created by Евгений Соболь on 4/2/20.
//  Copyright © 2020 Esobol. All rights reserved.
//

import AWSIoT
import Combine

class TemperatureManager {

    @Published var status = Status.disconnected
    @Published var temperature = 0.0

    static let shared = TemperatureManager()
    private let certificateId = "certificateId"
    private let dataManagerKey = "AWSIoTDataManager"
    private let thingName = "TempSensor"
    private lazy var dataManager = AWSIoTDataManager(forKey: dataManagerKey)

    private init() {}

    func connect() {
        setupAWS()
        setupCertificate()
        dataManager.connect(withClientId: UUID().uuidString, cleanSession: true, certificateId: certificateId) { (status) in
            DispatchQueue.main.async {
                switch status {
                case .connected:
                    self.status = .connected
                    self.registerForUpdates()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.getShadow()
                    }
                case .connecting:
                    self.status = .connecting
                case .connectionError, .connectionRefused, .disconnected, .unknown, .protocolError:
                    self.status = .disconnected
                @unknown default:
                    break
                }
            }
        }
    }

    private func getShadow() {
        dataManager.getShadow(thingName)
    }

    private func setupAWS() {
        let configuration = AWSServiceConfiguration(
            region: .USEast1,
            endpoint: AWSEndpoint(urlString: "https://a3tbb06100h7yp-ats.iot.us-east-1.amazonaws.com"),
            credentialsProvider: nil
        )!
        AWSIoTDataManager.register(with: configuration, forKey: dataManagerKey)
        AWSDDLog.sharedInstance.logLevel = .error
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
    }

    private func setupCertificate() {
        guard let url = Bundle.main.url(forResource: "certificate", withExtension: "p12"), let data = try? Data(contentsOf: url) else {
            fatalError("Unable to get certificate file")
        }
        AWSIoTManager.importIdentity(fromPKCS12Data: data, passPhrase: "", certificateId: certificateId)
    }

    private func registerForUpdates() {
        dataManager.register(withShadow: thingName, options: nil) { (thingName, operation, status, clientToken, payload) in
            print("Callback")
            switch operation {
            case .get where status == .accepted:
                guard let document = try? JSONDecoder().decode(AWSShadowDocument.self, from: payload) else { return }
                self.shadowUpdated(document.state.reported)
            case .update:
                guard let document = try? JSONDecoder().decode(AWSShadowUpdate.self, from: payload) else { return }
                self.shadowUpdated(document.current.state.reported)
            default:
                break
            }
        }
    }

    private func shadowUpdated(_ document: Shadow) {
        DispatchQueue.main.async {
            self.temperature = document.temperature
        }
    }

    enum Status {
        case connected
        case connecting
        case disconnected

        var description: String {
            switch self {
            case .connected:
                return NSLocalizedString("connected", comment: "")
            case .connecting:
                return NSLocalizedString("connecting", comment: "")
            case .disconnected:
                return NSLocalizedString("disconnected", comment: "")
            }
        }
    }
}

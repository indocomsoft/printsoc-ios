//
//  PaperUsage.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Combine
import Foundation

class PaperUsage: ObservableObject {
    static let shared = PaperUsage()

    struct Data {
        let bwPaperUsage: Int
        let bwPaperQuota: Int
        let colorPaperUsage: Int
        let colorPaperQuota: Int
    }

    @Published var data: Data?

    private var cancellable: AnyCancellable?

    init(data: Data? = nil) {
        self.data = data
        cancellable = update().sink(receiveCompletion: { _ in }, receiveValue: {})
    }

    // swiftlint:disable force_try
    private let regex = try! NSRegularExpression(
        pattern: "PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages.*?" +
            "Color-PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages",
        options: [.dotMatchesLineSeparators]
    )
    // swiftlint:enable force_try

    func update() -> AnyPublisher<Void, PrintsocError> {
        Account.shared.transportSession
            .flatMap { session in
                session.getPusageOutput().mapError { PrintsocError.transportSessionError($0) }
            }
            .flatMap { [weak self] pusageOutput -> AnyPublisher<Data, PrintsocError> in
                guard let self = self else {
                    return Fail(error: PrintsocError.strongReference)
                        .eraseToAnyPublisher()
                }
                let nsrange = NSRange(pusageOutput.startIndex ..< pusageOutput.endIndex,
                                      in: pusageOutput)
                guard let match = self.regex.firstMatch(in: pusageOutput, range: nsrange),
                    let bwUsageRange = Range(match.range(at: 1), in: pusageOutput),
                    let bwQuotaRange = Range(match.range(at: 2), in: pusageOutput),
                    let colorUsageRange = Range(match.range(at: 3), in: pusageOutput),
                    let colorQuotaRange = Range(match.range(at: 4), in: pusageOutput),
                    let bwPaperUsage = Int(String(pusageOutput[bwUsageRange])),
                    let bwPaperQuota = Int(String(pusageOutput[bwQuotaRange])),
                    let colorPaperUsage = Int(String(pusageOutput[colorUsageRange])),
                    let colorPaperQuota = Int(String(pusageOutput[colorQuotaRange]))
                else {
                    return Fail(error: PrintsocError.parsingError)
                        .eraseToAnyPublisher()
                }
                let data = Data(bwPaperUsage: bwPaperUsage, bwPaperQuota: bwPaperQuota,
                                colorPaperUsage: colorPaperUsage, colorPaperQuota: colorPaperQuota)
                return Just(data)
                    .setFailureType(to: PrintsocError.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .map { [weak self] in self?.data = $0 }
            .eraseToAnyPublisher()
    }
}

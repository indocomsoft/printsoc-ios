//
//  PaperUsage.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

struct PaperUsage {
    let bwPaperUsage: Int
    let bwPaperQuota: Int
    let colorPaperUsage: Int
    let colorPaperQuota: Int

    // swiftlint:disable force_try
    private static let regex = try! NSRegularExpression(
        pattern: "PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages.*?" +
            "Color-PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages",
        options: [.dotMatchesLineSeparators]
    )
    // swiftlint:enable force_try

    init?(pusageOutput: String) {
        let nsrange = NSRange(pusageOutput.startIndex ..< pusageOutput.endIndex, in: pusageOutput)
        guard let match = PaperUsage.regex.firstMatch(in: pusageOutput, range: nsrange),
            let bwUsageRange = Range(match.range(at: 1), in: pusageOutput),
            let bwQuotaRange = Range(match.range(at: 2), in: pusageOutput),
            let colorUsageRange = Range(match.range(at: 3), in: pusageOutput),
            let colorQuotaRange = Range(match.range(at: 4), in: pusageOutput),
            let bwPaperUsage = Int(String(pusageOutput[bwUsageRange])),
            let bwPaperQuota = Int(String(pusageOutput[bwQuotaRange])),
            let colorPaperUsage = Int(String(pusageOutput[colorUsageRange])),
            let colorPaperQuota = Int(String(pusageOutput[colorQuotaRange]))
        else {
            return nil
        }
        self.bwPaperUsage = bwPaperUsage
        self.bwPaperQuota = bwPaperQuota
        self.colorPaperUsage = colorPaperUsage
        self.colorPaperQuota = colorPaperQuota
    }

    static func get(from appState: AppState) -> PaperUsage? {
        guard let account = appState.getAccount() else {
            return nil
        }
        switch appState.authenticate(account: account) {
        case .failure: return nil
        case let .success(session):
            var error: NSError?
            session.channel.requestPty = true
            guard let result = session.channel.execute("/usr/local/bin/pusage", error: &error, timeout: 5) else {
                return nil
            }
            return PaperUsage(pusageOutput: result)
        }
    }
}

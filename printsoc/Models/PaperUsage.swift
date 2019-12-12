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
}

extension PaperUsage {
    init?(pusageOutput: String) {
        // swiftlint:disable force_try
        let regex = try! NSRegularExpression(
            pattern: "PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages.*?" +
                "Color-PS-printer paper usage: ([0-9]+) pages.*?Available quota: ([0-9]+) pages",
            options: [.dotMatchesLineSeparators]
        )
        // swiftlint:enable force_try
        let nsrange = NSRange(pusageOutput.startIndex ..< pusageOutput.endIndex, in: pusageOutput)
        guard let match = regex.firstMatch(in: pusageOutput, range: nsrange),
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
}

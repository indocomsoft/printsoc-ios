//
//  PrintUsageView.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintUsageView: View {
    var usage: PaperUsage

    private var bwTotal: CGFloat {
        CGFloat(usage.bwPaperQuota + usage.bwPaperUsage)
    }

    private var bwQuotaWidth: CGFloat {
        CGFloat(usage.bwPaperQuota) / bwTotal
    }

    private var bwUsageWidth: CGFloat {
        CGFloat(usage.bwPaperUsage) / bwTotal
    }

    var body: some View {
        List {
            PrintUsageSectionView(header: "B/W", quota: usage.bwPaperQuota,
                                  usage: usage.bwPaperUsage)
            PrintUsageSectionView(header: "Color", quota: usage.colorPaperQuota,
                                  usage: usage.colorPaperUsage)
        }.listStyle(GroupedListStyle())
    }
}

struct PrintUsageView_Previews: PreviewProvider {
    static let pusageOutput = """
    julius's hardcopy statistics this month:
    PS-printer paper usage: 8 pages
            Available quota: 117 pages (+od) (+one-time-topup:32)
            Quota topup: 50 pages (monthly); Allow to overdraft: 50 pages
    Color-PS-printer paper usage: 0 pages
            Available quota: 0 pages

    If you have purchased A0/A1 colour PS quota, please use the URL below:
            https://mysoc.nus.edu.sg/~eprint/forms
    """
    static var previews: some View {
        PrintUsageView(usage: PaperUsage(pusageOutput: pusageOutput)!)
            .frame(height: 500)
    }
}

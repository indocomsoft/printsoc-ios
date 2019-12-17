//
//  PrintUsageView.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintUsageView: View {
    @Binding var data: PaperUsage.Data?

    var body: some View {
        VStack {
            if data != nil {
                self.data.map { usage in
                    List {
                        PrintUsageSectionView(header: "B/W", quota: usage.bwPaperQuota,
                                              usage: usage.bwPaperUsage)
                        PrintUsageSectionView(header: "Color", quota: usage.colorPaperQuota,
                                              usage: usage.colorPaperUsage)
                    }
                    .listStyle(GroupedListStyle())
                }
            } else {
                Text("Quota information not available")
            }
        }
    }
}

struct PrintUsageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PrintUsageView(data: .constant(nil))
            PrintUsageView(data: .constant(PaperUsage.Data(bwPaperUsage: 8, bwPaperQuota: 117,
                                                           colorPaperUsage: 50,
                                                           colorPaperQuota: 0)))
            Spacer()
        }
    }
}

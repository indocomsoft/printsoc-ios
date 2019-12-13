//
//  PrintUsageSectionView.swift
//  printsoc
//
//  Created by Julius on 6/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct PrintUsageSectionView: View, Identifiable {
    // Necessary to prevent preconditionFailure crash
    var id: String { "\(header)-\(quota)-\(usage)" }

    var header: String
    var quota: Int
    var usage: Int
    var total: CGFloat {
        CGFloat(quota + usage)
    }

    var quotaWidth: CGFloat {
        CGFloat(quota) / total
    }

    var usageWidth: CGFloat {
        CGFloat(usage) / total
    }

    var body: some View {
        Section(header: Text(header)) {
            VStack {
                GeometryReader { geometry in
                    HStack {
                        HStack {
                            Circle()
                                .frame(width: geometry.size.height)
                                .foregroundColor(.blue)
                            Text("Quota")
                        }
                        HStack {
                            Circle()
                                .frame(width: geometry.size.height)
                                .foregroundColor(.red)
                            Text("Usage")
                        }
                    }
                }
                if total == 0 {
                    Text("Zero quota and usage").font(.caption)
                } else {
                    HStack {
                        Text(String(quota))
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: self.quotaWidth * geometry.size.width)
                                Rectangle()
                                    .foregroundColor(.red)
                                    .frame(width: self.usageWidth * geometry.size.width)
                            }
                        }
                        Text(String(usage))
                    }
                }
            }.padding()
        }
    }
}

struct PrintUsageSectionView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PrintUsageSectionView(header: "B/W", quota: 90, usage: 10)
            PrintUsageSectionView(header: "Color", quota: 0, usage: 00)
        }.listStyle(GroupedListStyle())
    }
}

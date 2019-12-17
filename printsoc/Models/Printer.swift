//
//  Printer.swift
//  printsoc
//
//  Created by Julius on 16/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import Foundation

struct Printer: Equatable {
    enum ColorMode: Equatable {
        case blackWhite
        case color

        init(printerName: String) {
            /// As of 16th December 2019, taken from https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues (requires login)
            if printerName.hasPrefix("cp") {
                self = .color
            } else {
                self = .blackWhite
            }
        }
    }

    struct Variant: OptionSet, Equatable {
        let rawValue: Int

        static let singleSided = Variant(rawValue: 1 << 0)
        static let doubleSided = Variant(rawValue: 1 << 1)
        static let noBanner = Variant(rawValue: 1 << 2)
        static let transparency = Variant(rawValue: 1 << 3)
    }

    /// As of 16th December 2019, taken from https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues (requires login)
    private static let confirmedStudentPrinters: Set<String> = ["psc008", "psc011", "psts", "pstsb",
                                                                "pstsc",
                                                                "cptsc", "cptsc-a3", "psx342a",
                                                                "psx342b"]
    /// As of 16th December 2019, taken from https://dochub.comp.nus.edu.sg/cf/guides/printing/print-queues (requires login)
    private static let suffixes: [String: Variant] = ["-dx": .doubleSided, "-sx": .singleSided,
                                                      "-nb": .noBanner, "-t": .transparency]

    let name: String
    let baseName: String
    let variant: Variant
    let colorMode: ColorMode
    let isStudentPrinter: Bool

    init(name: String) {
        self.name = name
        colorMode = ColorMode(printerName: name)

        let (baseName, variant): (String, Variant) =
            Printer.suffixes.reduce((name, [])) { result, kv in
                let (resultName, resultVariant) = result
                let (suffix, variant) = kv
                if resultName.contains(suffix) {
                    return (resultName.replacingOccurrences(of: suffix,
                                                            with: ""),
                            resultVariant.union(variant))
                } else {
                    return result
                }
            }
        self.baseName = baseName
        self.variant = variant
        isStudentPrinter = Printer.confirmedStudentPrinters.contains(baseName)
    }
}

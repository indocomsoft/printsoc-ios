//
//  TabLabel.swift
//  printsoc
//
//  Created by Julius on 13/12/19.
//  Copyright © 2019 Julius. All rights reserved.
//

import SwiftUI

struct TabLabel: View {
    let imageSystemName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
            Text(text)
        }
    }
}

struct TabLabel_Previews: PreviewProvider {
    static var previews: some View {
        TabLabel(imageSystemName: "house.fill", text: "Home")
    }
}

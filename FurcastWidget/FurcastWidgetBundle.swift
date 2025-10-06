//
//  FurcastWidgetBundle.swift
//  FurcastWidget
//
//  Created by Somayan Chakrabarti on 10/6/25.
//

import WidgetKit
import SwiftUI

@main
struct FurcastWidgetBundle: WidgetBundle {
    var body: some Widget {
        FurcastWidget()
        FurcastWidgetControl()
        FurcastWidgetLiveActivity()
    }
}

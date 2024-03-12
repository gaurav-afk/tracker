//
//  MapTip.swift
//  tracker_ios_app
//
//  Created by Gaurav Rawat on 2024-03-06.
//

import SwiftUI
import TipKit

struct MapTip: Tip{
    var title = Text("Share Location")
    
    var message: Text? = Text("click on wifi button to start/stop sharing location with others")
}

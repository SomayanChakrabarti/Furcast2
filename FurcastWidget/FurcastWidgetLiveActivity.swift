//
//  FurcastWidgetLiveActivity.swift
//  FurcastWidget
//
//  Created by Somayan Chakrabarti on 10/6/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FurcastWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FurcastWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FurcastWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FurcastWidgetAttributes {
    fileprivate static var preview: FurcastWidgetAttributes {
        FurcastWidgetAttributes(name: "World")
    }
}

extension FurcastWidgetAttributes.ContentState {
    fileprivate static var smiley: FurcastWidgetAttributes.ContentState {
        FurcastWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FurcastWidgetAttributes.ContentState {
         FurcastWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FurcastWidgetAttributes.preview) {
   FurcastWidgetLiveActivity()
} contentStates: {
    FurcastWidgetAttributes.ContentState.smiley
    FurcastWidgetAttributes.ContentState.starEyes
}

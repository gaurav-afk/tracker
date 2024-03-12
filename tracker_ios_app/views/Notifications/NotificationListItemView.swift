//
//  NotificationListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 25/2/2024.
//

import SwiftUI

struct NotificationListItemView: View {
    var notification: Notification
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(notification.title)")
                    .foregroundStyle(notification.read ? .gray : .black)
                Text("\(notification.content)")
                    .font(Font(CTFont(.application, size: 15)))
                    .foregroundStyle(notification.read ? .gray : .black)
            }
        }
    }
}

#Preview {
    NotificationListItemView(notification: Notification())
}

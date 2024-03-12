//
//  NotificationListView.swift
//  tracker_ios_app
//
//  Created by macbook on 24/2/2024.
//

import SwiftUI

struct NotificationListView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var rootScreen: RootViews
    
    var body: some View {
        VStack {
            List(notificationViewModel.notifications.sorted { $0.time > $1.time }) { notification in
                NavigationLink {
                    NotificationDetailView(notification: notification).environmentObject(notificationViewModel).environmentObject(userViewModel)
                } label: {
                    NotificationListItemView(notification: notification)
                }
            }
            .onAppear() {
                print("current user \(notificationViewModel.notifications)")
            }
            
        }
    }
}

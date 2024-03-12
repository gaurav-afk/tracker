//
//  MainView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import MapKit

struct MainView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @Binding var rootScreen: RootViews
    
    var body: some View {
        VStack{
            TabView {
                MapView().environmentObject(locationViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map") //Map
                }
                
                FollowingListView().environmentObject(userViewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Following") //Following
                }
                
                FollowedByListView().environmentObject(userViewModel).environmentObject(notificationViewModel)
                .tabItem {
                    Image(systemName: "eye")
                    Text("Followed By") //Followed By
                }
                
//                SelectedShareView().environmentObject(userViewModel).tabItem {
//                    Image(systemName: "shareplay")
//                    Text("Selected Share") //Selected Share
//                }
                
            }
            .navigationTitle(userViewModel.currentUser?.userData != nil ? "Welcome, \(userViewModel.currentUser!.userData!.nickName)" : "Logging out")
            .navigationBarTitleDisplayMode(.inline)
        }
     }

}

//#Preview {
//    MainView()
//}

//
//  ContentView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct ContentView: View {
//    @StateObject var userViewModel = UserViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var showAddFriendForm: Bool = false
    @State var rootScreen: RootViews = .main
    @State var viewSelection: Int? = nil
    
    var body: some View {
        VStack {
            if userViewModel.currentUser != nil {
                NavigationStack {
                    NavigationLink(destination: SettingsView().environmentObject(userViewModel), tag: 1, selection: $viewSelection) {}
                    
                    Group {
                        switch rootScreen {
                        case .main:
                            MainView(rootScreen: $rootScreen).environmentObject(userViewModel).environmentObject(notificationViewModel)
                        case .notifications:
                            NotificationListView(rootScreen: $rootScreen).environmentObject(userViewModel).environmentObject(notificationViewModel)
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            // for testing notification, remove later
//                            Button {
//                                print("sending test noti")
//                                notificationViewModel.testing(receiverId: userViewModel.currentUser!.identifier)
//                            } label: {
//                                Image(systemName: "exclamationmark.octagon")
//                                    .foregroundColor(.red)
//                                    .fontWeight(.bold)
//                                    .padding(4)
//                                    .background(.ultraThinMaterial)
//                                    .clipShape(.circle)
//                            }
                            
                            Button {
                                print("plus button pressed")
                                showAddFriendForm.toggle()
                            } label: {
                                Image(systemName: "person.badge.plus.fill")
                                    .padding(4)
                                    .background(.ultraThinMaterial)
                                    .clipShape(.circle)
                            }
                            .sheet(isPresented: $showAddFriendForm) {
                                AddFriendView(showAddFriendForm: $showAddFriendForm)
                                .presentationDragIndicator(.visible)
                                .presentationDetents([.fraction(0.3)])
                            }

                            
                            switch rootScreen {
                                case .main:
                                    Button {
                                        print("going to notifications")
                                        rootScreen = .notifications
                                    } label: {
                                        Image(systemName: "bell.fill")
                                            .padding(4)
                                            .background(.ultraThinMaterial)
                                            .clipShape(.circle)
                                    }
                                case .notifications:
                                    Button {
                                        print("going to home")
                                        rootScreen = .main
                                    } label: {
                                        Image(systemName: "house.fill")
                                            .padding(4)
                                            .background(.ultraThinMaterial)
                                            .clipShape(.circle)
                                    }
                            }
                            
                            
                            Menu {
                                Button {
                                    print("going to settings")
                                    viewSelection = 1
                                } label: {
                                    Text("Settings")
                                }

                                Button {
                                    print("menu clicked")
                                    userViewModel.logout()
                                } label: {
                                    Text("Logout")
                                }
                            } label: {
                                Label("More", systemImage: "line.horizontal.3")
                            }
                        }
                    }
                }
            }
            else {
                LoginView()
            }
        }
        .onAppear() {
//            locationViewModel.startLocationUpdate()
            
//            Task {
//                DispatchQueue.main.async {
//                    locationViewModel.startLocationUpdate()
//                }
//            }
        }

    }
}

#Preview {
    ContentView()
}

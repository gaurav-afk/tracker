//
//  FollowedByListView.swift
//  tracker_ios_app
//
//  Created by macbook on 27/2/2024.
//

import SwiftUI


struct FollowedByListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
//    @State private var followedByList: [String] = []
    @State private var followedByList: [(key: String, value: UserItemSummary)] = []
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UserError>?
    
    var body: some View {
        NavigationView {

            VStack {
                if(followedByList.isEmpty) {
                    Text("Not followed by anyone yet 🙂")
                }
                else {
                    List {
                        ForEach(followedByList, id: \.key) { followedBy, userItemSummary in
                            FriendListItemView(userId: followedBy, userItemSummary: userItemSummary, showAlert: $showAlert, sentResult: $sentResult).environmentObject(userViewModel).environmentObject(notificationViewModel)
                        }
                        .onDelete { indexSet in
                            Task {
                                print("deleting \(indexSet)")
                                for index in indexSet {
                                    let userToBeDeleted = followedByList[index].key
                                    
                                    do {
                                        try await userViewModel.unfollow(followerId: userToBeDeleted, targetId: userViewModel.currentUser!.identifier, isRemovingFollower: true)
                                        followedByList.remove(at: index)
                                        
                                        sentResult = .success(())
                                        showAlert.toggle()
                                    }
                                    catch let error as UserError {
                                        sentResult = .failure(error)
                                        showAlert.toggle()
                                    }
                                    catch let error {
                                        print("error in following list view \(error)")
                                        sentResult = .failure(.unknown)
                                        showAlert.toggle()
                                    }
                                }
                            }
                        }
                        .navigationTitle("Followed By") //Followed By
                        .alert(isPresented: $showAlert) {
                            switch sentResult {
                            case .success:
                                return Alert(title: Text("Invitation Sent"), message: Text("Waiting for the user to accept"))
                            case .none:
                                return Alert(title: Text("Unknown"), message: Text("Unknown"))
                            case .failure(let error):
                                let errMsg: String
                                switch error {
                                case .cannotBeYourself:
                                    errMsg = "Cannot follow yourself"
                                case .alreadyFollowed:
                                    errMsg = "You have already followed this user"
                                case .invalidUser:
                                    errMsg = "User not Found"
                                default:
                                    errMsg = "Unknown error"
                                }
                            
                                return Alert(title: Text("Failed to send Request"), message: Text(errMsg))
                            }
                        }
                    }
                }
            }
            .onAppear() {
//                followedByList = userViewModel.currentUser?.userData?.followedBy.keys.map {$0} ?? []
                
                followedByList = userViewModel.currentUser?.userData?.followedBy.sorted {$0.value.connectionTime > $1.value.connectionTime} ?? []
            }
        }
           
    }
}


//#Preview {
//    FollowedByListView(followedBy: ["user1"])
//        .preferredColorScheme(.dark)
//}

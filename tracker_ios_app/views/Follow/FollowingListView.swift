//
//  FollowingListView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct FollowingListView: View {
    @EnvironmentObject var userViewModel: UserViewModel
//    @State private var followings: [String] = []
    @State private var followings: [(key: String, value: UserItemSummary)] = []
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UserError>? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if(followings.isEmpty){
                    Text("Not following anyone yet 🙂")
                }
                else {
                    List {
                        ForEach(followings, id: \.key) { follower, userItemSummary in
                            FriendListItemView(userId: follower, userItemSummary: userItemSummary, icon: "location.viewfinder", showAlert: $showAlert, sentResult: $sentResult)
                        }
                        .onDelete { indexSet in
                            Task {
                                print("deleting \(indexSet)")
                                for index in indexSet {
                                    let userToBeDeleted = followings[index].key
                                    
                                    do {
                                        try await userViewModel.unfollow(followerId: userViewModel.currentUser!.identifier, targetId: userToBeDeleted, isRemovingFollower: false)
                                        followings.remove(at: index)
                                        
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
                        .navigationTitle("Following") //Following
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
                print("following list appear")
                
//                followings = userViewModel.currentUser?.userData?.following.keys.map {$0} ?? []
                followings = userViewModel.currentUser?.userData?.following.sorted {$0.value.connectionTime > $1.value.connectionTime} ?? []
                
                print("following is \(followings)")
            }
        }
    }
}
//#Preview {
//    FollowerListView()
//}


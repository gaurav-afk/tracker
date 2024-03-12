//
//  AddFriendView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct AddFriendView: View {
    @State private var userToFollow: String = ""
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var showAddFriendForm: Bool
    @State private var showAlert: Bool = false
    @State private var sentResult: Result<Void, UserError>? = nil
    
    var body: some View {
        VStack {
                VStack(alignment: .leading) {
                    Text("User Email/Phone: ")
                    .padding(.top)
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.purple)
                        TextField("", text: $userToFollow)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 2)
                    }
                    .frame(height: 40)
                    .padding(.trailing)
                }
            
            HStack {
                Button {
                    print("add button pressed")

                    Task {
                        do {
                            print("request sending")
                            try await notificationViewModel.requestFollow(target: userToFollow, by: userViewModel.currentUser!.identifier)
                            sentResult = .success(())
                            showAlert.toggle()
                        }
                        catch let error as UserError {
                            print("catching error in adding friend view")
                            sentResult = .failure(error)
                            showAlert.toggle()
                        }
                        catch let error {
                            print("error in add friend view \(error)")
                            sentResult = .failure(.unknown)
                            showAlert.toggle()
                        }
                    }
                } label: {
                    Text("Invite")
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .fontWeight(.semibold)
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
                
                Spacer()
                
                Button {
                    print("cancel button pressed")
                    showAddFriendForm.toggle()

                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .fontWeight(.semibold)
                .padding()
            }
        }
        .padding(.horizontal)
    }
}

//#Preview {
//    AddFriendView()
//        .preferredColorScheme(.dark)
//}

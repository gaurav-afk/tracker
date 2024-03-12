//
//  FriendListItemView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI
import PhotosUI

struct FriendListItemView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var notificationViewModel: NotificationViewModel
    private var userId: String
    var icon: String
    private var userItemSummary: UserItemSummary
    private var avatarImage: UIImage?
    private var dateFormatter: DateFormatter
    @Binding private var showAlert: Bool
    @Binding private var sentResult: Result<Void, UserError>?
    
//    init(userId: String, userItemSummaryDict: [String: Any], icon: String) {
    init(userId: String, userItemSummary: UserItemSummary, icon: String = "", showAlert: Binding<Bool>, sentResult: Binding<Result<Void, UserError>?>) {
//        do {
            self.userId = userId
            self.userItemSummary = userItemSummary
            self.icon = icon
            self._showAlert = showAlert
            self._sentResult = sentResult
            
            dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            
            guard let imgData = Data(base64Encoded: userItemSummary.profilePic) else {
                print("Error decoding Base64 string to Data, user \(userId)")
                return
            }
            
            // Create UIImage from Data
            self.avatarImage = UIImage(data: imgData)
//        }
//        catch {
//            print("cannot decode userItemSummary")
//        }
    }
    
    var body: some View {
        VStack{
            
            HStack {
                HStack {
                    if let img = avatarImage {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                            .shadow(radius: 5)
                    }
                    else {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            
                    Text("\(userItemSummary.nickName)")
                }
                Spacer()
                
                if(userViewModel.currentUser?.userData?.following.keys.contains(userId) ?? false){
                    Image(systemName: icon)
                      .font(.title)
                      .foregroundColor(.green)
                }
                else {
                    Button{
                        Task {
                            do {
                                print("tyring")
                                try await notificationViewModel.requestFollow(target: userId, by: userViewModel.currentUser!.identifier)
                                sentResult = .success(())
                                print("success")
//                                sentResult = .failure(.unknown)
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
                        Text("Follow")
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.vertical, 5)
            
            HStack {
                Text("id: \(self.userId)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("accepted: \(dateFormatter.string(from: userItemSummary.connectionTime))")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
}

//#Preview {
//    FriendListItemView()
//}

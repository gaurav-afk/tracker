//
//  SignUpView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email: String = ""
    @State private var nickName: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var signUpError: SignUpError? = nil
    
    var body: some View {
        
        
        GeometryReader{ geo in
            
            ZStack{
                Color.black
                    
                    Image(.loginBack)
                        .resizable()
                        .blur(radius: 5)
                        .frame(width: geo.size.width, height: geo.size.height*1.2)
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .opacity(1)
                        .blur(radius: 1)
                        .clipShape(.rect(cornerRadius: 15))
                    
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                        .frame(width: geo.size.width, height: geo.size.height*1.2)
                        .opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(alignment: .center) {
                        
                        Spacer()
                        
                        Text("User Name")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        Text("Nickname")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        TextField("Enter your Nickname", text: $nickName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        Text("Password")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        Text("Confirm Password")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        Button {
                            Task {
                                do {
                                    try await userViewModel.signUp(email: email, nickName: nickName, password: password, confirmPassword: confirmPassword)
                                }
                                catch let error as SignUpError {
                                    signUpError = error
                                }
                                catch {
                                    print("unknown error")
                                    signUpError = .unknown
                                }
                            }
                        } label: {
                            Text("Create Account")
                                .foregroundStyle(.white)
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .tint(.green)
                        .buttonStyle(.borderedProminent)
                        .alert(item: $signUpError) { error in
                            let errMsg: String
                            switch error {
                            case .alreadyExist:
                                errMsg = "The username is already used."
                            case .weakPassword:
                                errMsg = "Password is too weak."
                            case .confirmPwdNotMatch:
                                errMsg = "Password does not match with the confirm password."
                            case .emptyInputs:
                                errMsg = "All input fields are mandatory."
                            default:
                                errMsg = "Unknown error"
                            }
                            return Alert(title: Text("Sign Up Failed"), message: Text(errMsg))
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
        }.edgesIgnoringSafeArea(.all)
    }
}

//#Preview {
////    SignUpView().environmentObject(UserViewModel())
//    SignUpView().environmentObject(UserViewModel(authenticationService: AuthenticationService(), preferenceService: PreferenceService(), userRepository: UserRepository(db: Firestore.firestore())))
//}

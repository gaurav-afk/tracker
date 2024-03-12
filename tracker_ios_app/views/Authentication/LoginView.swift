//
//  LoginView.swift
//  tracker_ios_app
//
//  Created by macbook on 22/2/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var viewSelection: Int? = nil
    @State private var loginError: LoginError? = nil
    
    var body: some View {
        GeometryReader{ geo in
            
            NavigationStack {
                
                ZStack{
                    Image(.loginBack)
                        .resizable()
                        .blur(radius: 5)
                        .frame(width: geo.size.width*1.1, height: geo.size.height*1.2)
                        .aspectRatio(contentMode: .fill)
                        .opacity(1)
                        .blur(radius: 1)
                        .clipShape(.rect(cornerRadius: 15))
                        
                    
                    LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
                        .frame(width: geo.size.width*1.1, height: geo.size.height*1.2)
                        .opacity(0.8)
                        .ignoresSafeArea()
                    VStack(alignment: .center){
                        NavigationLink(destination: SignUpView().environmentObject(userViewModel), tag: 1, selection: $viewSelection){}
                        
                        Text("User Name")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                        
                        Text("Password")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .foregroundColor(.orange)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange, lineWidth: 3))
                            .padding()
                            .padding(.bottom, 20)
                        
                        HStack {
                            Button{
                                rememberMe.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: rememberMe ? "checkmark.square" : "square")
                                        .foregroundColor(rememberMe ? .blue : .gray)
                                        .font(.system(size: 20))
                                    
                                    Text("Remember Me")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                        }
                        
                        HStack {
                            Button {
                                Task {
                                    do {
                                        try await userViewModel.login(email: email, password: password, rememberMe: rememberMe)
                                    }
                                    catch let error as LoginError {
                                        print("having error \(error)")
                                        loginError = error
                                    }
                                    catch let error {
                                        print("unknown error \(error)")
                                        loginError = .unknown
                                    }
                                }
                            } label: {
                                Text("Login")
                                    .foregroundStyle(.white)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            .tint(.green)
                            .buttonStyle(.borderedProminent)
                            .alert(item: $loginError){ error in
                                let errMsg: String
                                switch error {
                                case .emptyUsernameOrPwd:
                                    errMsg = "Please enter both username and password."
                                case .invalidUser, .wrongPwd:
                                    errMsg = "Invalid username or password."
                                default:
                                    errMsg = "Unknown error"
                                }
                                return Alert(title: Text("Login Failed"), message: Text(errMsg))
                            }
                            
                            Spacer()
                            
                            Button {
                                print("sign up clicked")
                                viewSelection = 1
                            } label: {
                                Text("Sign up")
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .font(.title2)
                            }
                            .tint(.indigo)
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                    .padding(.horizontal, 20)
                }
                
            }
        }.edgesIgnoringSafeArea(.all)
        
    }
        
}

//#Preview {
//    LoginView().environmentObject(UserViewModel())
//}

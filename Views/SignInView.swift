import SwiftUI

struct SignInView: View {
    //Properties
    
    @State private var email: String = ""
    @State private var passwoed: String = ""
    @State private var error: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = "Oh No 😩"
    @State private var isLoading: Bool = false
    
    
    func errorCheck() -> String? {
        if email.trimmingCharacters(in: .whitespaces).isEmpty ||
            passwoed.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please fill in all fields."
        }
        return nil
    }// errorCheck
    
    func clear(){
        email = ""
        passwoed = ""
    }// clear
    
    func signIn() {
        if let error = errorCheck() {
            self.error = error
            self.showingAlert = true
            return
        }
        
        isLoading = true
        AuthService.signIn(email: email, password: passwoed) { user in
            self.clear()
            self.isLoading = false
        } onError: { errorMessage in
            print("Error: \(errorMessage)")
            self.error = errorMessage
            self.showingAlert = true
            self.isLoading = false
        }
        
    }// signIn
    
    //Body
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 1) {
                
                ZStack {
                    
                    Image("gradient")
                        .resizable()
                        .cornerRadius(5)
                        .offset(y: -13)
                        .ignoresSafeArea()
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, -65)
                        .frame(width: 235)
                    
                }// ZStack
                
                
                Group {
                    
                    FormField(value: $email, icon: "envelope.fill", placeholder: "E-mail")
                    
                    FormField(value: $passwoed, icon: "lock.fill", placeholder: "Password", isScure: true)
                    
                    if isLoading {
                        ProgressView("Signing In...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        Button {
                            signIn()
                        } label: {
                            Text("Sign In")
                                .modifier(ButtonModifiers(background: .cyan, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text(alertTitle), message: Text(error), dismissButton: .default(Text("Ok")))
                        }
                    }
                    
                    HStack{
                        Text("New User?")
                        NavigationLink(destination: SignUpView()){
                            Text("Create an Account.")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.accent)
                        }// NavigationLink
                        
                    }// HStack
                    
                }// Group
                .padding(13)
                
            }// VStack
            .padding(.bottom, 200)
            
        } // NavigationView
        
        
    }
}

#Preview {
    SignInView()
}

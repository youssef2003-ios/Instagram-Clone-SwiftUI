import SwiftUI

struct SignUpView: View {
    // Properties
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var passwoed: String = ""
    @State private var profileImage: Image?
    @State private var pickedImage: Image?
    @State private var imageData: Data = Data()
    @State private var showImagePicker: Bool = false
    @State private var showingActionSheet: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var uploadStatus: String = ""
    @State private var error: String = ""
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = "Oh No 😩"
    @State private var isLoading: Bool = false
    
    func loadImage() {
        guard let inputImage = pickedImage else { return }
        profileImage = inputImage
    }
    
    func errorCheck() -> String? {
        if username.trimmingCharacters(in: .whitespaces).isEmpty ||
            email.trimmingCharacters(in: .whitespaces).isEmpty ||
            passwoed.trimmingCharacters(in: .whitespaces).isEmpty ||
            imageData.isEmpty {
            return "Please fill in all fields and provide an image"
        }
        return nil
    }
    
    func clear() {
        self.username = ""
        self.email = ""
        self.passwoed = ""
        self.imageData = Data()
        self.profileImage = Image (systemName: "person.crop.square.badge.camera.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 125, height: 125, alignment: .center) as? Image
    }
    
    func signUp() {
        if let error = errorCheck() {
            self.error = error
            self.showingAlert = true
            return
        }
        
        isLoading = true
        AuthService.signUp(username: username, email: email, password: passwoed, imageData: imageData) { user in
            self.clear()
            self.isLoading = false
        } onError: { errorMessage in
            print("Error: \(errorMessage)")
            self.error = errorMessage
            self.showingAlert = true
            self.isLoading = false
        }
    }// signUp
        
    
    // Body
    var body: some View {
        
        ScrollView {
            
            VStack( spacing: 20) {
                
                HStack {
                    
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100, alignment: .center)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Welcome")
                            .font(.system(size: 32, weight: .black, design: .serif))
                        
                        Text("Sign Up To Start")
                            .font(.system(size: 16, weight: .medium))
                    }// VStack
                    
                }// HStack
                
                
                VStack {
                    
                    Group {
                        
                        if profileImage != nil {
                            profileImage?.resizable()
                                .clipShape(.circle)
                                .frame(width: 122, height: 122, alignment: .center)
                                .padding(.top, 20)
                                .onTapGesture {
                                    showingActionSheet = true
                                }
                            
                        } else {
                            Image(systemName: "person.crop.square.badge.camera.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130, alignment: .center)
                                .padding(.top, 20)
                                .onTapGesture {
                                    showingActionSheet = true
                                }
                        }
                    }// Group
                    
                }// VStack
                
                Group {
                    FormField(value: $username, icon: "person.fill", placeholder: "Username")
                    FormField(value: $email, icon: "envelope.fill", placeholder: "E-mail")
                    FormField(value: $passwoed, icon: "lock.fill", placeholder: "Password", isScure: true)
                    
                    if isLoading {
                        ProgressView("Signing Up...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        Button {
                            signUp()
                        } label: {
                            Text("Sign Up")
                                .modifier(ButtonModifiers(background: .green, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text(alertTitle), message: Text(error), dismissButton: .default(Text("Ok")))
                        }
                    }
                    
                }// Group
                .padding(.vertical, 5)
                
            }// VStack
            .padding()
            
        }// ScrollView
        .padding(.top, 25)
        .sheet(isPresented: $showImagePicker) {
            loadImage()
        } content: {
            ImagePicker(pickedImage: $pickedImage, imageData: $imageData, showImagePicker: $showImagePicker)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(""), buttons: [
                .default(Text("Choose A Photo"), action: {
                    self.sourceType = .photoLibrary
                    self.showImagePicker = true
                }),
                .default(Text("Take A Photo"), action: {
                    self.sourceType = .camera
                    self.showImagePicker = true
                }),
                .cancel()
            ])
        }
        
        
        
        
    }
}



#Preview {
    SignUpView()
}

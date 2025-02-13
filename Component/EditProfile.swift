import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI


struct EditProfile: View {
    
    @EnvironmentObject var session: SessionStore
    
    @State private var username: String = ""
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
    @State private var bio: String = ""
    
    init(session: UserModel?) {
        _bio = State(initialValue: session?.bio ?? "")
        _username = State(initialValue: session?.username ?? "")
    }
    
    func loadImage() {
        guard let inputImage = pickedImage else { return }
        profileImage = inputImage
    }
    
    func errorCheck() -> String? {
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please fill in all fields and provide an image"
        }
        return nil
    }
    
    func clear() {
        self.username = ""
        self.bio = ""
        self.imageData = Data()
        self.profileImage = Image (systemName: "person.circle.fill")
        
    }
    
    func editProfile() {
        
        if let error = errorCheck() {
            self.error = error
            self.showingAlert = true
            return
        }
        
        isLoading = true
        
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let storageProfileUserId = StorageService.storeProfileId(userId: userId)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        if imageData.isEmpty {
            // No New image, update only bio and username
            let firestoreUserId = AuthService.getUserId(userId: userId)
            firestoreUserId.updateData([
                "username": username,
                "bio": bio
            ]) { error in
                if let error = error {
                    self.error = error.localizedDescription
                    self.showingAlert = true
                }
                self.isLoading = false
            }
        } else {
            // New image provided, upload it
            StorageService.editProfile(userId: userId, username: username, bio: bio, imageData: imageData, metaData: metaData, storageProfileImageRef: storageProfileUserId) { errorMessg in
                self.error = errorMessg
                self.showingAlert = true
                self.isLoading = false
            }
        }
        
        self.isLoading = false
        self.clear()
        
    }// editProfile
    
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                Text("Edit Profile")
                    .font(.largeTitle)
                
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
                            WebImage(url: URL(string: session.session?.profileImageUrl ?? ""))
                                .resizable()
                                .scaledToFit()
                                .clipShape(.circle)
                                .frame(width: 200, height: 200, alignment: .center)
                                .padding(.top, 20)
                                .onTapGesture {
                                    showingActionSheet = true
                                }
                        }
                        
                    }// Group
                    
                }// VStack2
                
                Group {
                    
                    FormField(value: $username, icon: "person.fill", placeholder: "Username")
                    FormField(value: $bio, icon: "book.fill", placeholder: "Bio")
                    
                    if isLoading {
                        ProgressView("Signing In...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    } else {
                        Button {
                            editProfile()
                        } label: {
                            Text("Edit")
                                .modifier(ButtonModifiers(background: .green, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                        }
                        .padding()
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text(alertTitle), message: Text(error), dismissButton: .default(Text("Ok")))
                        }
                    }
                    
                }// Group
                .padding(.vertical, 5)
                
            }// VStack1
            .padding()
            
        }// ScrollView
        .navigationTitle(session.session?.username ?? "")
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

//#Preview {
//    EditProfile()
//}

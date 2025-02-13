import SwiftUI

struct Post: View {
    
    @State private var postImage: Image?
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
    @State private var text: String = ""
    
    func loadImage() {
        guard let inputImage = pickedImage else {return}
        postImage = inputImage
    }
    
    func errorCheck() -> String? {
        if text.trimmingCharacters(in: .whitespaces).isEmpty ||
            imageData.isEmpty {
            return "Please add a caption and provide an image"
        }
        return nil
    }
    
    func clear() {
        self.text = ""
        self.imageData = Data()
        self.postImage = Image(systemName: "photo.badge.plus.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 170, height: 170, alignment: .center) as? Image
            
    }
    
    
    func uploadPost() {
        if let error = errorCheck() {
            self.error = error
            self.showingAlert = true
            return
        }
        
        isLoading = true
        PostService.uploadPost(caption: text, imageData: imageData) {
            self.clear()
            self.isLoading = false
        } onError: { errorMessg in
            print("Error: \(errorMessg)")
            self.error = errorMessg
            self.showingAlert = true
            self.isLoading = false
        }
        
        
    }// UploadPost
    
    // Body
    var body: some View {
        
        NavigationStack{
            
            VStack {
                
                VStack {
                    
                    if postImage != nil {
                        postImage?.resizable()
                            .frame(width: 300, height: 290, alignment: .center)
                            .cornerRadius(10)
                            .onTapGesture {
                                showingActionSheet = true
                            }
                        
                    } else {
                        VStack{
                            Image(systemName: "photo.badge.plus.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 170, height: 170, alignment: .center)
                                .onTapGesture {
                                    showingActionSheet = true
                                }
                            
                            HStack{
                                Text("Select image")
                                    .font(.title2)
                                
                                Image(systemName: "arrow.up.to.line.compact")
                            }// HStack
                            .padding(.top, -10)
                        }
                    }// VStack3
                }// VStack2
                
                TextEditor(text: $text)
                    .frame(height: 140)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black)
                    )
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Uploading Post...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Button {
                        // Action
                        uploadPost()
                    } label: {
                        Text("Upload Post")
                            .font(.title)
                            .modifier(ButtonModifiers(background: .black, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text(alertTitle), message: Text(error), dismissButton: .default(Text("Ok")))
                    }
                }
                
                
            }// VStack1
            .padding()
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(pickedImage: $pickedImage, imageData: $imageData, showImagePicker: $showImagePicker)
            }
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text(""), message: Text(""), buttons: [
                    .default(Text("Choose A Photo"), action: {
                        self.sourceType = .photoLibrary
                        self.showImagePicker = true
                    }),
                    
                        .default(Text("Take A Photo"), action: {
                            self.sourceType = .camera
                            self.showImagePicker = true
                        })
                ])
            }
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            
        }// NavigationStack
        
    }
}



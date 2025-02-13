import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct Profile: View {
    
    @EnvironmentObject var session: SessionStore
    @StateObject var profileService = ProfileService()
    @State private var selection = 1
    @State private var showAlert: Bool = false
    @State private var isLinkActive: Bool = false
    
    let threeColumns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        
        NavigationStack{
            
            ScrollView {
                
                VStack {
                    
                    ProfileHeader(user: self.session.session, postsCount: profileService.posts.count, followers: $profileService.followers, following: $profileService.following)
                        .padding(.top, -20)
                    
                    VStack(alignment: .leading) {
                        Text(session.session?.bio ?? "")
                            .font(.headline)
                            .lineLimit(1)
                    }
                    
                    NavigationLink(destination: EditProfile(session: session.session), isActive: $isLinkActive) {
                        Button {
                            // Action
                            isLinkActive = true
                        } label: {
                            Text("Edit Profile")
                                .modifier(ButtonModifiers(background: .accent, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                        }// Button
                        .padding(.horizontal)
                    }
                    
                    Picker("", selection: $selection) {
                        Image(systemName: "circle.grid.2x2.fill").tag(0)
                        Image(systemName: "person.circle").tag(1)
                    }// Picker
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 5)
                    
                    if selection == 0 {
                        LazyVGrid(columns: threeColumns) {
                            ForEach(profileService.posts, id: \.postId) { posts in
                                
                                WebImage(url: URL(string: posts.mediaUrl))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 3)
                                    .clipped()
                            }// ForEach
                        }// LazyVGrid
                    }
                    else {
                        ScrollView{
                            VStack{
                                ForEach(profileService.posts, id: \.postId) { posts in
                                    
                                    PostCardImageView(post: posts)
                                    PostCard(post: posts)
                                    
                                }// ForEach
                            }// VStack
                        }// ScrollView
                    }
                    
                    
                }// VStack
                
            }// ScrollView
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    // Action
                }, label: {
                    Image(systemName: "person.fill")
                }), trailing: Button(action: {
                    // Action
                    showAlert = true
                }, label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .accentColor(.red)
                }))
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Are you sure to sign out!"), message: Text(""), primaryButton: .destructive(Text("Sign Out"), action: {
                    session.signOut()
                }), secondaryButton: .cancel())
            }
            .onAppear {
                profileService.loadUserPosts(userId: Auth.auth().currentUser!.uid)
                session.loadCurrentUser() // Ensure this method refreshes the user data
            }
            
        }// NavigationStack
        
    }
}

//#Preview {
//    Profile()
//}

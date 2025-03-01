import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct PostCardImageView: View {
    
    @EnvironmentObject var session: SessionStore
    @StateObject var profileService = ProfileService()
    
    @State var post: PostModel
    @State private var user: UserModel? = nil
    @State private var showDeleteAlert = false
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                
                WebImage(url: URL(string: post.profileImage)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFit()
                    .clipShape(.circle)
                    .frame(width: 60, height: 60, alignment: .center)
                    .shadow(color: .gray, radius: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    if let user = user, user.uId != Auth.auth().currentUser?.uid {
                        
                        NavigationLink(destination: UserProfileView(user: user)) {
                            HStack{
                                Text("\(post.username) .")
                                    .font(.headline)
                                    .foregroundColor(.accent)
                                
//                                FollowButton(user: user, followingCount: $profileService.following, followersCount: $profileService.followers, followCheck: $profileService.followCheck)
//                                    .modifier(ButtonModifiers(background: nil, foregroundColor: .cyan, width: 70, height: 10, fontSize: 14))
//                                    .padding(.leading, -13)
                            }
                        }
                        
                    } else {
                        
                        NavigationLink(destination: ProfileView(session: _session)) {
                            Text("\(post.username) .")
                                .font(.headline)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Text((Date(timeIntervalSince1970: post.date)).timeAgo())
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.top, -6)
                }// VStack
                .padding(.leading, 10)
                
                Spacer()
                
                // Show delete button only if the current user owns the post
                if post.ownerId == Auth.auth().currentUser?.uid {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 10)
                    .alert("Delete Post", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete", role: .destructive) {
                            deletePost()
                        }
                    } message: {
                        Text("Are you sure you want to delete this post? This action cannot be undone.")
                    }
                }
                
                
            }// HStack
            .padding(.leading)
            .padding(.top, 10)
            
            Text(post.caption)
                .lineLimit(nil)
                .padding(.leading, 16)
                .padding(.trailing, 32)
            
            WebImage(url: URL(string: post.mediaUrl)!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.size.width, height: 400, alignment: .center)
                .clipped()
            
        }// VStack
        .onAppear {
            fetchUser()
            if let user = user {
                profileService.refreshFollow(userId: user.uId)
            }
            
            // Ensure the post profile image is updated
            AuthService.storeRoot.collection("users").document(post.ownerId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let updatedUser = try? UserModel(fromDictionary: data)
                    DispatchQueue.main.async {
                        self.post.profileImage = updatedUser?.profileImageUrl ?? post.profileImage
                        self.post.username = updatedUser?.username ?? post.username
                        self.user?.bio = updatedUser?.bio ?? user!.bio
                    }
                }
            }
        }
    }
    
    func fetchUser() {
        AuthService.storeRoot.collection("users").document(post.ownerId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error)")
                return
            }
            
            if let data = snapshot?.data() {
                self.user = try? UserModel(fromDictionary: data)
                if let user = self.user {
                    self.profileService.refreshFollow(userId: user.uId)
                }
            }
        }
    }// fetchUser
    
    func deletePost() {
        PostService.deleteProfilePost(post: post, profileService: profileService) {
            print("Profile post deleted successfully")
        } onError: { errorMessage in
            print(errorMessage)
        }
        
    }// deletePost
    
    
    
}

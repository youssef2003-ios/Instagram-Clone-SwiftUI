import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct UserProfileView: View {
    
    var user: UserModel
    
    @StateObject var profileService: ProfileService = ProfileService()
    
    @State private var selection = 1
    
    let threeColumns = [GridItem(), GridItem(), GridItem()]
    
    var body: some View {
        
        ScrollView {
            
            VStack{
                
                    ProfileHeader(user: user, postsCount: profileService.posts.count, followers: $profileService.followers, following: $profileService.following)
                
                VStack(alignment: .leading) {
                    Text(user.bio)
                        .font(.headline)
                        .lineLimit(1)
                }

                
                HStack {
                    FollowButton(user: user, followingCount: $profileService.following , followersCount: $profileService.followers, followCheck: $profileService.followCheck)
                        .modifier(ButtonModifiers(background: .accent, foregroundColor: .white, width: nil, height: 20, fontSize: 20))
                        
                }.padding(.horizontal)
                
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
        .navigationBarTitle(Text("\(user.username)"))
        .onAppear {
            profileService.loadUserPosts(userId: user.uId)
            profileService.refreshFollow(userId: user.uId)
        }

        
        
    }
}

//#Preview {
//    UserProfileView()
//}

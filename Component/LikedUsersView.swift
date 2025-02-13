import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

struct LikedUsersView: View {
    
    let users: [UserModel]
    
    @EnvironmentObject var session: SessionStore
    @ObservedObject var profileService = ProfileService()
    
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        
        NavigationView {
            
            List(users, id: \.uId) { user in
                
                if user.uId != Auth.auth().currentUser!.uid {
                    
                    NavigationLink(destination: UserProfileView(user: user)) {
                        
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            
                            Text(user.username)
                                .font(.headline)
                        }// HStack
                    }
                } else {
                    NavigationLink(destination: ProfileView(session: _session)) {
                        
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            
                            Text(user.username)
                                .font(.headline)
                        }// HStack
                    }
                }
            }// List
            .navigationTitle("Liked by")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }// NavigationView
       
        
    }
}



import SwiftUI
import SDWebImageSwiftUI

struct LikesView: View {
    
    let users: [UserModel]
    
    var body: some View {
        
        HStack(spacing: -10) { // Overlapping images
            ForEach(users.prefix(3), id: \.uId) { user in
                
                WebImage(url: URL(string: user.profileImageUrl))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
        .onAppear {
            print("Users in LikesView: \(users.map { $0.username })") // Debug
        }
        
    }
}

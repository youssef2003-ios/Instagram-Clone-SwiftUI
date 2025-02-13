import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct ProfileHeader: View {
    
    var user: UserModel?
    var postsCount: Int
    
    @StateObject var profileService = ProfileService()
    
    @Binding var followers: Int
    @Binding var following: Int
    
    var body: some View {
        
        HStack {
            
            VStack {
                
                if user != nil {
                    
                    WebImage(url:  URL(string: user!.profileImageUrl)!) { image in image
                            .resizable()
                            .scaledToFit()
                            .clipShape(.circle)
                            .frame(width: 95, height: 95, alignment: .trailing)
                            .padding(.leading)
                            .padding(.top, 30)
                        
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 55, height: 55)
                    }
                    
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 55, height: 55)
                        .padding(.leading)
                }
                
                Text(user?.username ?? "")
                    .font(.headline)
                    .bold()
                    .padding(.leading)
                    .padding(.top, -8)
                
            }// VStack
            
            VStack {
                
                HStack{
                    Spacer()
                    
                    VStack{
                        Text("Posts")
                            .font(.headline)
                        Text("\(postsCount)")
                            .font(.title)
                            .bold()
                    }// VStack
                    .padding(.top, 42)
                    
                    Spacer()
                    
                    VStack {
                        Text("Followers")
                            .font(.headline)
                        Text("\(followers)")
                            .font(.title)
                            .bold()
                    }// VStack
                    
                    .padding(.top, 42)
                    
                    Spacer()
                    
                    VStack {
                        Text("Following")
                            .font(.headline)
                        Text("\(following)")
                            .font(.title)
                            .bold()
                    }// VStack
                    .padding(.top, 42)
                    
                    Spacer()
                    
                }// HStack
                
            }// VStack
            
        }// HStack
        
    }
}

//#Preview {
//    ProfileHeader()
//}

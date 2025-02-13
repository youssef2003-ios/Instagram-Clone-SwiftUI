import SwiftUI

struct FollowButton: View {
    
    @StateObject var followService = FollowService()
    @StateObject var profileService = ProfileService()
    
    var user: UserModel
    
    @Binding var followingCount: Int
    @Binding var followersCount: Int
    @Binding var followCheck: Bool
    
    
    init(user: UserModel, followingCount: Binding<Int>, followersCount: Binding<Int>, followCheck: Binding<Bool>) {
        self.user = user
        self._followingCount = followingCount
        self._followersCount = followersCount
        self._followCheck = followCheck
    }
    
    
    func follow() {
        
        if !followCheck {
            
            followService.follow(userId: user.uId) { followingCount in
                DispatchQueue.main.async {
                    self.followingCount = followingCount
                    profileService.refreshFollow(userId: user.uId)
                    self.followCheck = true
                }
                
            } followersCount: { followersCount in
                DispatchQueue.main.async {
                    self.followersCount = followersCount
                    profileService.refreshFollow(userId: user.uId)
                }
            }
            
        } else {
            
            followService.unFollow(userId: user.uId) { followingCount in
                DispatchQueue.main.async {
                    self.followingCount = followingCount
                    profileService.refreshFollow(userId: user.uId)
                    self.followCheck = false
                }
            } followersCount: { followersCount in
                DispatchQueue.main.async {
                    self.followersCount = followersCount
                    profileService.refreshFollow(userId: user.uId)
                }
            }
            
        }
        
    }// Follow
    
    
    var body: some View {
        
        Button {
            //Action
            follow()
        } label: {
            Text( followCheck ? "unFollow" : "Follow")
        }
        
        
    }
}

//#Preview {
//    FollowButton()
//}

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

class ProfileService: ObservableObject {
    
    @Published var posts: [PostModel] = []
    @Published var following: Int = 0
    @Published var followers: Int = 0
    @Published var followCheck: Bool = false
    
    static var following = AuthService.storeRoot.collection("following")
    static var followers = AuthService.storeRoot.collection("followers")
    
    static func followingCollection(userId: String) -> CollectionReference {
        return following.document(userId).collection("following")
    }
    
    static func followersCollection(userId: String) -> CollectionReference {
        return followers.document(userId).collection("followers")
    }
    
    static func followingId(userId: String) -> DocumentReference {
        return following.document(Auth.auth().currentUser!.uid).collection("following").document(userId)
    }
    
    static func followersId(userId: String) -> DocumentReference {
        return followers.document(userId).collection("followers").document(Auth.auth().currentUser!.uid)
    }
    
    
    func loadUserPosts(userId: String) {
        
        PostService.loadUserPost(userId: userId) { posts in
            self.posts = posts
        }
        
        refreshFollow(userId: userId)
    }// loadUserPosts
    
    func following(userId: String) {
        
        ProfileService.followingCollection(userId: userId).getDocuments { querySnapshot, error in
            if let doc = querySnapshot?.documents {
                self.following = doc.count
            }
        }
    }// follows
    
    func followers(userId: String) {
        
        ProfileService.followersCollection(userId: userId).getDocuments { querySnapshot, error in
            if let doc = querySnapshot?.documents {
                self.followers = doc.count
            }
        }
    }// followers
    
    func followState(userid: String) {
        
        ProfileService.followingId(userId: userid).getDocument { document, error in
            
            if let doc = document, doc.exists {
                self.followCheck = true
            } else {
                self.followCheck = false
            }
        }
    }// followState

    func refreshFollow(userId: String) {
        followState(userid: userId)
        following(userId: userId)
        followers(userId: userId)
    }

    
    
}// ProfileService



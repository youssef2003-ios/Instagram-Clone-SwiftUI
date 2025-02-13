import Foundation
import Firebase

class FollowService: ObservableObject {
    
    func updateFollowCount(userId: String, followingCount: @escaping (_ followingCount: Int) -> Void, followersCount: @escaping (_ followersCount: Int) -> Void) {
        
        ProfileService.followingCollection(userId: userId).getDocuments { snap, error in
            
            if let doc = snap?.documents {
                followingCount(doc.count)
            }
        }
        
        ProfileService.followersCollection(userId: userId).getDocuments { snap, error in
            
            if let doc = snap?.documents {
                followersCount(doc.count)
            }
        }
        
    }// updateFollowCount
    
    
    func manageFollow(userId: String, followCheck: Bool, followingCount: @escaping (_ followingCount: Int) -> Void, followersCount: @escaping (_ followersCount: Int) -> Void) {
        
        if !followCheck {
            follow(userId: userId, followingCount: followingCount, followersCount: followersCount)
        } else {
            unFollow(userId: userId, followingCount: followingCount, followersCount: followersCount)
        }
        
    }// manageFollow
    
    func follow(userId: String, followingCount: @escaping (_ followingCount: Int) -> Void, followersCount: @escaping (_ followersCount: Int) -> Void) {
        
        ProfileService.followingId(userId: userId).setData([:]) { error in
            if error == nil {
                self.updateFollowCount(userId: userId, followingCount: followingCount, followersCount: followersCount)
            }
        }
        
        ProfileService.followersId(userId: userId).setData([:]) { error in
            if error == nil {
                self.updateFollowCount(userId: userId, followingCount: followingCount, followersCount: followersCount)
            }
        }
        
    }// Follow
    
    func unFollow(userId: String, followingCount: @escaping (_ followingCount: Int) -> Void, followersCount: @escaping (_ followersCount: Int) -> Void) {
        
        ProfileService.followingId(userId: userId).getDocument { document, error in
            if let doc = document, doc.exists {
                doc.reference.delete()
                self.updateFollowCount(userId: userId, followingCount: followingCount, followersCount: followersCount)
            }
        }
        
        ProfileService.followersId(userId: userId).getDocument { document, error in
            if let doc = document, doc.exists {
                doc.reference.delete()
                self.updateFollowCount(userId: userId, followingCount: followingCount, followersCount: followersCount)
            }
        }
        
    }// unFollow
    
    
}// FollowService

import  SwiftUI
import Foundation
import Firebase
import FirebaseAuth

class PostCardService: ObservableObject {
    
    @Published var post: PostModel!
    @Published var isLiked = false
    @Published var likedUsers: [UserModel] = []  // Array to hold users who liked
    
    //        func hasLikedPost() {
    //            guard let userId = Auth.auth().currentUser?.uid else { return }
    //            PostService.postUserId(userId: post.ownerId).collection("posts").document(post.postId)
    //                .getDocument { snapshot, error in
    //                    if let error = error {
    //                        print("Error fetching like state: \(error.localizedDescription)")
    //                        return
    //                    }
    //
    //                    if let data = snapshot?.data(), let isLiked = data[userId] as? Bool {
    //                        DispatchQueue.main.async {
    //                            self.isLiked = isLiked
    //                        }
    //                    }
    //                }
    //        }// hasLikedPost
    
    
    func hasLikedPost() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        PostService.postUserId(userId: post.ownerId).collection("posts").document(post.postId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching like state: \(error.localizedDescription)")
                    return
                }
                
                if let data = snapshot?.data() {
                    DispatchQueue.main.async {
                        self.isLiked = data[userId] as? Bool ?? false
                    }
                    
                    // Extract liked user IDs
                    let likedUserIds = data.compactMap { key, value in
                        (value as? Bool == true) ? key : nil
                    }
                    
                    // Fetch details for these users
                    self.fetchUsersFromIds(userIds: likedUserIds)
                }
            }
    }
    
    
    private func fetchUsersFromIds(userIds: [String]) {
        
        let userCollection = Firestore.firestore().collection("users")
        var fetchedUsers: [UserModel] = []
        
        let dispatchGroup = DispatchGroup()
        
        for userId in userIds {
            dispatchGroup.enter()
            
            userCollection.document(userId).getDocument { document, error in
                if let document = document, document.exists, let data = document.data() {
                    if let user = try? UserModel(fromDictionary: data) {
                        fetchedUsers.append(user)
                    }
                } else {
                    print("Failed to fetch user with ID: \(userId)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Fetched Users: \(fetchedUsers.map { $0.username })") // Debugging
            
            DispatchQueue.main.async {
                self.likedUsers = [] // Clear the array first
                self.likedUsers = fetchedUsers // Assign the new array
            }
        }
    }
    
    
    func like() {
        post.likeCount += 1
        isLiked = true
        updateLikeStatus(liked: true)
        refreshLikedUsers()
    }// like
    
    func unLike() {
        post.likeCount -= 1
        isLiked = false
        updateLikeStatus(liked: false)  // Ensure false here
        refreshLikedUsers()  // Call to update the liked users
    }// unLike
    
    
    private func updateLikeStatus(liked: Bool) {
        
        PostService.postUserId(userId: post.ownerId).collection("posts").document(post.postId).updateData(["likeCount":post.likeCount, "\(Auth.auth().currentUser!.uid)": liked])
        
        PostService.allPosts.document(post.postId).updateData(["likeCount":post.likeCount, "likes.\(Auth.auth().currentUser!.uid)": liked])
        
        PostService.timeLineUserId(userId: post.ownerId).collection("timeLine").document(post.postId).updateData(["likeCount":post.likeCount, "\(Auth.auth().currentUser!.uid)": liked])
    }
    
    func refreshLikedUsers() {
        let postRef = PostService.postUserId(userId: post.ownerId).collection("posts").document(post.postId)
        
        postRef.getDocument { snapshot, error in
            if let data = snapshot?.data() as? [String: Any] {
                let likedUserIds = data.compactMap { (key: String, value: Any) -> String? in
                    guard key != "likeCount", let isLiked = value as? Bool, isLiked else { return nil }
                    return key
                }
                print("Liked User IDs: \(likedUserIds)") // Debugging
                self.fetchUsersFromIds(userIds: likedUserIds)
            } else {
                print("Error fetching data or casting to [String: Any]")
            }
            
        }
    }
    
    
    
    
}// PostCardService





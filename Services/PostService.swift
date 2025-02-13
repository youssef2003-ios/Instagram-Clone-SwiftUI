import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class PostService {
    
    static var posts = AuthService.storeRoot.collection("posts")
    static var allPosts = AuthService.storeRoot.collection("allPosts")
    static var timeLine = AuthService.storeRoot.collection("timeLine")
    
    static func postUserId (userId: String) -> DocumentReference {
        return posts.document(userId)
    }
    
    static func timeLineUserId (userId: String) -> DocumentReference {
        return timeLine.document(userId)
    }
    
    
    static func uploadPost(caption: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessg: String) -> Void) {
        
        guard let userId = Auth.auth().currentUser?.uid else {return}
        
        let postId = PostService.postUserId(userId: userId).collection("posts").document().documentID
        
        let storagePostUserId = StorageService.storePostId(postId: postId)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        StorageService.savePostPhoto(userId: userId, caption: caption, postId: postId, imageData: imageData, metaData: metaData, storagePostRef: storagePostUserId, onSuccess: onSuccess, onError: onError)
        
    }// uploadPost
    
    
    static func loadUserPost(userId: String, onSuccess: @escaping(_ posts: [PostModel]) -> Void) {
        
        PostService.postUserId(userId: userId).collection("posts").addSnapshotListener { snapshot, error in
            
            guard let snap = snapshot else {
                print("snapShot Error:\(error!.localizedDescription)")
                return
            }
            
            var posts = [PostModel]()
            
            for doc in snap.documents {
                var dict = doc.data()
                dict["postId"] = doc.documentID
                guard let decoder = try? PostModel(fromDictionary: dict) else {
                    return
                }
                
                posts.append(decoder)
            }
            
            onSuccess(posts)
        }// getDocuments
        
    }// loadUserPost
    
    
    static func loadAllPosts(onSuccess: @escaping (_ posts: [PostModel]) -> Void, onError: @escaping (_ error: String) -> Void) {
        
        allPosts.order(by: "date", descending: true).getDocuments { snapshot, error in
            
            if let error = error {
                onError("Error fetching all posts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                onError("No posts found.")
                return
            }
            
            let posts = documents.compactMap { doc -> PostModel? in
                let data = doc.data()
                return try? PostModel(fromDictionary: data)
            }
            
            onSuccess(posts)
        }
    }// loadAllPosts
    
    
    static func loadPostComment(postId: String, onSuccess: @escaping (_ posts: PostModel) -> Void) {
        
        PostService.allPosts.document(postId).getDocument { snapshot, error in
            
            guard let snap = snapshot else {
                print("snapShot Error:\(error!.localizedDescription)")
                return
            }
            
            let dict = snap.data()
            
            guard let decoded = try? PostModel(fromDictionary: dict!) else {return}
            
            onSuccess(decoded)
        }
        
    }// loadPost
    
    
    static func deleteProfilePost(post: PostModel, profileService: ProfileService, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userPostRef = PostService.posts.document(userId).collection("posts").document(post.postId)

        userPostRef.delete { error in
            if let error = error {
                onError("Error deleting from user posts: \(error.localizedDescription)")
                return
            }

            PostService.allPosts.document(post.postId).delete { error in
                if let error = error {
                    onError("Error deleting from all posts: \(error.localizedDescription)")
                    return
                }

                let storageRef = Storage.storage().reference(withPath: "posts").child(post.postId)
                storageRef.delete { error in
                    if let error = error {
                        print("Warning: Could not delete image: \(error.localizedDescription)")
                    }
                    // Remove the post from profileService after successful deletion
                    DispatchQueue.main.async {
                        profileService.posts.removeAll { $0.postId == post.postId }
                    }
                    onSuccess()
                }
            }
        }
    }

    
    
    
//    static func deletePost(postId: String, userId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
//        // Delete from user's posts collection
//        PostService.postUserId(userId: userId).collection("posts").document(postId).delete { error in
//            if let error = error {
//                onError(error.localizedDescription)
//                return
//            }
//            
//            // Delete from allPosts collection
//            PostService.allPosts.document(postId).delete { error in
//                if let error = error {
//                    onError(error.localizedDescription)
//                    return
//                }
//                
//                // Delete the image from Storage
//                let storageRef = Storage.storage().reference().child("posts").child(userId).child(postId)
//                storageRef.delete { error in
//                    if let error = error {
//                        onError(error.localizedDescription)
//                        return
//                    }
//                    
//                    onSuccess()
//                }
//            }
//        }
//    }
    
    
    
    
    
}// PostService


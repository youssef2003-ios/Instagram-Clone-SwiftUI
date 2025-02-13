import Foundation
import Firebase
import FirebaseAuth

class CommentService: ObservableObject {
    
    @Published var comments: [CommentModel] = []
    @Published var isLoading: Bool = false
    
    
    var post: PostModel!
    var postId: String!
    var listener: ListenerRegistration!
    
    static var commentsRef = AuthService.storeRoot.collection("comments")
    
    static func commentsId(postId: String) -> DocumentReference {
        return commentsRef.document(postId)
    }
    
    
    func postComment(commentText: String, postId: String, profileIamge: String, username: String, ownerId: String, onSuccess: @escaping() -> Void, onError: @escaping(_ error: String) -> Void) {
        
        let commentRef = CommentService.commentsId(postId: postId).collection("comments").document()
        
        let comment = CommentModel(id: commentRef.documentID, commentText: commentText, postId: postId, profileIamge: profileIamge, username: username, date: Date().timeIntervalSince1970, ownerId: ownerId)
        
        guard let dict = try? comment.asDictionary() else {return}
        
        CommentService.commentsId(postId: postId).collection("comments").addDocument(data: dict) { error in
            if let err = error {
                onError(err.localizedDescription)
                return
            }
            onSuccess()
        }
        
    }// postComment
    
    
    func getComment(postId: String, onSuccess: @escaping ([CommentModel]) -> Void,onError: @escaping(_ error: String) -> Void, newComment: @escaping (CommentModel) -> Void, listener: @escaping(_ listenHandle: ListenerRegistration) -> Void) {
        
        let listenerPosts = CommentService.commentsId(postId: postId).collection("comments").order(by: "date", descending: false).addSnapshotListener { snapshot, error in
            
            guard let snap = snapshot else {return}
            
            var comments = [CommentModel]()
            
            snap.documentChanges.forEach { diff in
                
                // if Added a new comment
                if diff.type == .added {
                    
                    var dict = diff.document.data()
                    dict["id"] = diff.document.documentID  // Add document ID to the dictionary
                    
                    guard let decoded = try? CommentModel(fromDictionary: dict)  else {return}
                    
                    newComment(decoded)
                    comments.append(decoded)
                }
                
                //                if diff.type == .modified {
                //                    print("modified")
                //                }
                //
                //                if diff.type == .removed {
                //                    print("removed")
                //                }
            }
            
            onSuccess(comments)
        }
        
        listener(listenerPosts)
    }// getComment
    
    
    func loadComments() {
        
        self.comments = []
        
        self.isLoading = true
        
        self.getComment(postId: postId) { comments in
            if self.comments.isEmpty  {
                self.comments = comments
            }
            
        } onError: { error in
            print("Error to get Comment \(error)")
        } newComment: { comment in
            if !self.comments.isEmpty  {
                self.comments.append(comment)
            }
            
        } listener: { listenHandle in
            self.listener = listenHandle
        }
        
    }// loadComments
    
    
    func addComment(commentText: String, onSuccess: @escaping() -> Void) {
        
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        
        guard let username = Auth.auth().currentUser?.displayName else {return}
        
        guard let profileImage = Auth.auth().currentUser?.photoURL?.absoluteString else {return}
        
        
        self.postComment(commentText: commentText, postId: post.postId, profileIamge: profileImage, username: username, ownerId: currentUser) {
            onSuccess()
        } onError: { error in
            
        }
        
    }// addComment
    
    
    func deleteComment(postId: String, commentId: String, onSuccess: @escaping() -> Void, onError: @escaping(_ error: String) -> Void) {
        // Get current user ID
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            onError("User not authenticated")
            return
        }
        
        // Get the comment reference
        let commentRef = CommentService.commentsId(postId: postId).collection("comments").document(commentId)
        
        // First get the comment to check ownership
        commentRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data(),
                  let ownerId = data["ownerId"] as? String else {
                onError("Comment not found")
                return
            }
            
            // Check if current user is the owner
            if ownerId == currentUserId {
                // User is owner, proceed with deletion
                DispatchQueue.main.async {
                    self?.comments.removeAll { $0.id == commentId }
                }
                
                commentRef.delete { error in
                    if let err = error {
                        // If deletion fails, restore the comment locally
                        if let comment = self?.comments.first(where: { $0.id == commentId }) {
                           
                            self?.comments.append(comment)
                        }
                        onError(err.localizedDescription)
                    } else {
                        onSuccess()
                    }
                }
            } else {
                onError("You can only delete your own comments")
            }
        }
    }// deleteComment
    
    func removeComment(_ comment: CommentModel) {
        // Remove the comment from the list
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments.remove(at: index)
        }
    }// removeComment
    
    
    
}// CommentService

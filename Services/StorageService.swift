import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static var storage = Storage.storage()
    
    static var storageRoot = storage.reference(forURL: "gs://market-6250d.appspot.com")
    
    static var storageProfile = storageRoot.child("profile")
    
    static var storagePost = storageRoot.child("posts")
    
    static func storePostId (postId: String) -> StorageReference {
        return storagePost.child(postId)
    }
    
    static func storeProfileId (userId: String) -> StorageReference {
        return storageProfile.child(userId)
    }
    
    
    
    static func editProfile(userId: String, username: String, bio: String, imageData: Data, metaData: StorageMetadata, storageProfileImageRef: StorageReference, onError: @escaping (_ errorMessg: String) -> Void) {
        
        if imageData.isEmpty {
            let firestoreUserId = AuthService.getUserId(userId: userId)
            firestoreUserId.updateData([
                "username": username,
                "bio": bio
            ]) { error in
                if let error = error {
                    onError(error.localizedDescription)
                }
            }
            return
        }
        
        storageProfileImageRef.putData(imageData, metadata: metaData) { _, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            }
            
            storageProfileImageRef.downloadURL { url, error in
                if let metaImageUrl = url?.absoluteString {
                    let firestoreUserId = AuthService.getUserId(userId: userId)
                    firestoreUserId.updateData([
                        "profileImageUrl": metaImageUrl,
                        "username": username,
                        "bio": bio
                    ])
                } else if let error = error {
                    onError(error.localizedDescription)
                }
            }
        }
    }// editProfile
    
    
    static func saveProfileImage(userId: String, username: String, email: String, imageData: Data, metaData: StorageMetadata, storageProfileImageRef: StorageReference, onSuccess: @escaping (_ user: UserModel) -> Void, onError: @escaping (_ errorMessg: String) -> Void) {
        
        storageProfileImageRef.putData(imageData, metadata: metaData) { StorageMetadata, error in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storageProfileImageRef.downloadURL { url, error in
                
                if let metaImageUrl = url?.absoluteString {
                    
                    // Change photo
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges { erroe in
                            if erroe != nil {
                                onError(erroe!.localizedDescription)
                                return
                            }
                        }
                    }
                    
                    let firestoreUserId = AuthService.getUserId(userId: userId)
                    let user = UserModel(uId: userId, username: username, email: email, profileImageUrl: metaImageUrl, searchName: username.splitString(), bio: "")
                    
                    guard let dict = try? user.asDictionary() else {return}
                    
                    firestoreUserId.setData(dict) { error in
                        if error != nil {
                            onError(error!.localizedDescription)
                            return
                        }
                    }
                    
                    onSuccess(user)
                }// metaImageUrl
                
            }// downloadURL
            
        }// putData
        
    } // saveProfileImage
    
    
    
    static func savePostPhoto(userId: String, caption: String, postId: String, imageData: Data, metaData: StorageMetadata, storagePostRef: StorageReference, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessg: String) -> Void) {
        
        storagePostRef.putData(imageData, metadata: metaData) { StorageMetadata, error in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            storagePostRef.downloadURL { url, error in
                
                if error != nil {
                    onError(error!.localizedDescription)
                    return
                }
                
                if let mediaUrl = url?.absoluteString {
                    
                    let firestorePostRef = PostService.postUserId(userId: userId).collection("posts").document(postId)
                    
                    let post = PostModel(caption: caption, likes: [:], geoLocation: "", ownerId: userId, postId: postId, username: Auth.auth().currentUser!.displayName!, profileImage: Auth.auth().currentUser!.photoURL!.absoluteString, mediaUrl: mediaUrl, date: Date().timeIntervalSince1970, likeCount: 0)
                    
                    guard let dict = try? post.asDictionary() else {return}
                    
                    firestorePostRef.setData(dict) { error in
                        if error != nil {
                            onError(error!.localizedDescription)
                            return
                        }
                        
                        PostService.timeLineUserId(userId: userId).collection("timeLine").document(postId).setData(dict)
                        
                        PostService.allPosts.document(postId).setData(dict)
                        
                        onSuccess()
                    }
                }// mediaUrl
                
            }// downloadURL
            
        }// putData
        
    }// savePostPhoto
    
    
    
    
} // StorageService

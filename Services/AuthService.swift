import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class AuthService {
    
    static var storeRoot = Firestore.firestore()
    
    static func getUserId (userId: String) -> DocumentReference {
        return storeRoot.collection("users").document(userId)
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping (_ user: UserModel) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            guard let userId = authResult?.user.uid else {return}
            
            let storageProfileUserId = StorageService.storeProfileId(userId: userId)
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            
            StorageService.saveProfileImage(userId: userId, username: username, email: email, imageData: imageData, metaData: metaData, storageProfileImageRef: storageProfileUserId, onSuccess: onSuccess, onError: onError)
        }
        
    }// signUp
    
    static func signIn(email: String, password: String, onSuccess: @escaping (_ user: UserModel) -> Void, onError: @escaping (_ errorMessage: String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            guard let userId = authData?.user.uid else {return}
            
            let firestoreUserId = getUserId(userId: userId)
            firestoreUserId.getDocument { document, error in
                
                if let dict = document?.data() {
                    guard let decodedUser = try? UserModel.init(fromDictionary: dict) else {return}
                    onSuccess(decodedUser)
                }
            }
        }
        
    }// signIn
    
    
    
    
}// AuthService

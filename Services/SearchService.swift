import Foundation
import SwiftUI
import FirebaseAuth


class SearchService {
    
    static func searchUser(input: String, onSuccess: @escaping (_ user: [UserModel]) -> Void) {
        
        let userCollecton = AuthService.storeRoot.collection("users")
        
        userCollecton.whereField("searchName", arrayContains: input.lowercased().removeWhiteSpace()).getDocuments {querySnapshot, error in
            
            guard let snap = querySnapshot else {
                print("Error in fetch searchUser \(error!.localizedDescription)")
                return
            }
            
            var users = [UserModel]()
            
            for doc in snap.documents {
                let dict = doc.data()
                
                guard let decoded = try? UserModel.init(fromDictionary: dict) else {return}
                
                if decoded.uId != Auth.auth().currentUser!.uid{
                    users.append(decoded)
                }
                
                onSuccess(users)
            }
        }
    }//searchUser
    
    
    
    
    
    
}// SearchService

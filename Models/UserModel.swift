import SwiftUI
import Foundation


struct UserModel: Encodable, Decodable, Equatable{
    
    var uId: String
    var username: String
    var email: String
    var profileImageUrl: String
    var searchName: [String]
    var bio: String
    
}

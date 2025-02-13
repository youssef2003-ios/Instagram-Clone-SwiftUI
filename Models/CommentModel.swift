import Foundation

struct CommentModel: Encodable, Decodable, Identifiable {
    
    var id: String
    var commentText: String
    var postId: String
    var profileIamge: String
    var username: String
    var date: Double
    var ownerId: String
}

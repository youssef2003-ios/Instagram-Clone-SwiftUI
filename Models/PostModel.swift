import Foundation

struct PostModel: Encodable, Decodable {
    
    var caption: String
    var likes: [String: Bool] // Store user IDs who liked the post
    var geoLocation: String
    var ownerId: String
    var postId: String
    var username: String
    var profileImage: String
    var mediaUrl: String
    var date: Double
    var likeCount: Int
}

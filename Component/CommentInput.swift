import SwiftUI
import SDWebImageSwiftUI

struct CommentInput: View {
    
    @EnvironmentObject var session: SessionStore
    @ObservedObject var commentService = CommentService()
    @State var text: String = ""
    
    init(post: PostModel?, postId: String?) {
        if post != nil {
            commentService.post = post
        } else {
            handlePostInput(postId: postId!)
        }
    }
    
    func handlePostInput(postId: String) {
        
        PostService.loadPostComment(postId: postId) { posts in
            commentService.post = posts
        }
    }
    
    
    func sendComment() {
        guard !text.isEmpty else { return }
        
        let commentToSend = text
        DispatchQueue.main.async {
            self.text = ""
        }
        
        commentService.addComment(commentText: commentToSend) {}
    }
    // sendComment
    
    
    var body: some View {
        
        HStack{
            
            WebImage(url: URL(string: session.session!.profileImageUrl))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaledToFit()
                .clipShape(.circle)
                .frame(width: 45, height: 45, alignment: .center)
                .shadow(color: .gray, radius: 3)
                .padding(.leading)
            
            HStack{
                TextEditor(text: $text)
                    .frame(height: 33)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 8, style: .circular).stroke(Color.black, lineWidth: 2))
                
                Button {
                    // Action
                    sendComment()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.cyan)
                        .imageScale(.medium)
                        .padding(.trailing)
                }
                
                
            }// HStack
            
        }// HStack
        .padding(.bottom, 23)
        
    }
}

//#Preview {
//    CommentInput()
//}

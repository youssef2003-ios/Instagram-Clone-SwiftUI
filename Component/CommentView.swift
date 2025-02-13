import SwiftUI

struct CommentView: View {
    
    @StateObject var commentService = CommentService()
    @EnvironmentObject var session: SessionStore
    
    @State var post: PostModel?
    @State var postId: String?
    
    var body: some View {
        
        NavigationStack{
            
            VStack(spacing: 10) {
                
                ScrollView {
                    
                    if !commentService.comments.isEmpty {
                        
                        ForEach(commentService.comments) { comment in
                            CommentCard(commentService: commentService, comment: comment)
                                .padding(.top)
                        }
                    }
                    
                }// ScrollView
                
                CommentInput(post: post, postId: postId)
                
            }// VStack
            .navigationTitle("Comments")
            .onAppear {
                commentService.postId = self.post == nil ? self.postId : self.post?.postId
                commentService.loadComments()
                session.loadCurrentUser() // Ensure this method refreshes the user data
            }
            .onDisappear {
                if commentService.listener != nil {
                    commentService.listener.remove()
                }
            }
            
        }// NavigationStack
        
    }
}

//#Preview {
//    CommentView()
//}

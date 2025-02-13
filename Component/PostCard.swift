import SwiftUI
import SDWebImageSwiftUI

struct PostCard: View {
    
    @StateObject var postCardService = PostCardService()
    @ObservedObject var commentService = CommentService()
    
    @State private var animate: Bool = false
    @State private var showLikedUsers = false
    
    private let duration: Double = 0.2
    
    private var animationScale: CGFloat{
        postCardService.isLiked ? 1.2 : 1.0
    }
    
    init(post: PostModel) {
        let service = PostCardService()
        service.post = post
        service.hasLikedPost()
        self._postCardService = StateObject(wrappedValue: service)
    }
    
    var body: some View {
        
        
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(spacing: 15) {
                
                Button {
                    // Action
                    
                    withAnimation(.easeInOut(duration: duration)) {
                        animate = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.duration, execute: {
                        self.animate = false
                        
                        if self.postCardService.isLiked {
                            self.postCardService.unLike()
                        }
                        else {
                            self.postCardService.like()
                        }
                    })
                    
                } label: {
                    Image(systemName: (self.postCardService.isLiked) ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .center)
                        .foregroundColor((self.postCardService.isLiked) ? .red : .accentColor)
                        .scaleEffect(animationScale)
                }
                .padding()
                
                NavigationLink(destination: CommentView(post: self.postCardService.post)) {
                    Image(systemName: "bubble.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20, alignment: .center)
                }
                                
                Image(systemName: "paperplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20, alignment: .center)
                    .padding(.leading, 12)
                
                Spacer()
                
            }// HStack
            .padding(.horizontal, 14)
            
            VStack {
                if postCardService.post.likeCount > 0 {
                    // Tappable like count
                    HStack{
           
                        LikesView(users: postCardService.likedUsers)
                        
                        Text("\(postCardService.post.likeCount) likes")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }// HStack
                    .onTapGesture {
                        showLikedUsers.toggle()
                    }
                    .sheet(isPresented: $showLikedUsers) {
                        LikedUsersView(users: postCardService.likedUsers)
                    }
                }
            }// VStack
            .padding(.leading, 19)
            .padding(.top, -8)
            
            NavigationLink(destination: CommentView(post: self.postCardService.post)) {
                    Text("View Comments")
                        .font(.caption)
                        .imageScale(.small)
                        .padding(.leading)
            }
            
        }// VStack
        .onAppear {
            postCardService.hasLikedPost()
            postCardService.refreshLikedUsers()
        }
        
        
    }
}

//#Preview {
//    PostCard()
//}

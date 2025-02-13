import SwiftUI
import FirebaseAuth

struct Main: View {
    
    @StateObject var timelineService = TimelineService()
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        
        NavigationStack{
            
            ScrollView {
                
                VStack {
                    
                    ForEach(self.timelineService.timelinePosts, id: \.postId) { post in
                        
                        PostCardImage(post: post, timelineService: timelineService)
                            .padding(.top, 10)
                        PostCard(post: post)
                        
                    }// ForEach
                    
                }// VStack
                
            }// ScrollView
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("logoo")
                        .resizable()
                        .frame(width: 95, height: 32)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "paperplane.fill")
                        .imageScale(.large)
                }
            }
            .onAppear {
                self.timelineService.loadAllPosts()
                session.loadCurrentUser() // Ensure this method refreshes the user data
            }
            
        }// NavigationStack
        
        
    }
}

//#Preview {
//    Main()
//}

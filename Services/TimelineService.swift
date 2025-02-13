import FirebaseFirestore
import FirebaseAuth

class TimelineService: ObservableObject {
    
    @Published var timelinePosts: [PostModel] = []
    
    func loadAllPosts() {
        PostService.loadAllPosts { posts in
            DispatchQueue.main.async {
                self.timelinePosts = posts
            }
        } onError: { error in
            print(error)
        }
    }// loadAllPosts
    
}// TimelineService

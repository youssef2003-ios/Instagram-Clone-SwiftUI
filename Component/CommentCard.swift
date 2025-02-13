import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct CommentCard: View {
    
    @ObservedObject var commentService: CommentService
    @EnvironmentObject var session: SessionStore
    
    @State private var isDeleting = false
    @State private var showDeleteAlert = false
    @State var comment: CommentModel
    
    private var isOwner: Bool {
        Auth.auth().currentUser?.uid == comment.ownerId
    }
    
    var body: some View {
        
        if isOwner {
            
            HStack{
                
                NavigationLink(destination: ProfileView(session: _session)) {
                    WebImage(url: URL(string: comment.profileIamge)) { image in image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                            .shadow(color: .gray, radius: 3)
                            .padding(.leading)
                            .onAppear {
                                SDImageCache.shared.clearMemory()
                                SDImageCache.shared.clearDisk(onCompletion: nil)
                            }
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(comment.username)
                        .font(.subheadline)
                        .bold()
                    
                    Text(comment.commentText)
                        .font(.caption)
                }// VStack
                
                Spacer()
                
                Text((Date(timeIntervalSince1970: comment.date)).timeAgo())
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                Button {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash.fill")
                        .opacity(isDeleting ? 0.5 : 1)
                }
                .foregroundColor(.red)
                .padding(.trailing, 10)
                .alert("Delete Comment", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        // Call the delete function after confirmation
                        withAnimation {
                            isDeleting = true
                            commentService.deleteComment(postId: comment.postId, commentId: comment.id) {
                                // Once the comment is deleted, remove it from the list
                                commentService.removeComment(comment)
                                withAnimation(.easeOut(duration: 0.1)) {
                                    isDeleting = false
                                }
                            } onError: { error in
                                isDeleting = false
                                print("Failed to delete comment: \(error)")
                            }
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete this comment? This action cannot be undone.")
                }
                
            }// HStack
            .opacity(isDeleting ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.1), value: isDeleting)
            
        } else{
            HStack{
                
                NavigationLink(destination: UserProfileView(user: UserModel(uId: comment.ownerId, username: comment.username, email: "", profileImageUrl: comment.profileIamge, searchName: [], bio: ""))) {
                    
                    WebImage(url: URL(string: "\(comment.profileIamge)")) { image in image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 30, height: 30)
                            .shadow(color: .gray, radius: 3)
                            .padding(.leading)
                            .onAppear {
                                SDImageCache.shared.clearMemory()
                                SDImageCache.shared.clearDisk(onCompletion: nil)
                            }
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 30, height: 30)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(comment.username)
                        .font(.subheadline)
                        .bold()
                    
                    Text(comment.commentText)
                        .font(.caption)
                }// VStack
                
                Spacer()
                
                Text((Date(timeIntervalSince1970: comment.date)).timeAgo())
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 15)
            }// HStack
            .onAppear {
                AuthService.storeRoot.collection("users").document(comment.ownerId).addSnapshotListener { snapshot, error in
                    if let data = snapshot?.data() {
                        let newUsername = data["username"] as? String ?? comment.username
                        let newProfileImage = data["profileImageUrl"] as? String ?? comment.profileIamge
                        print("Firestore Update → Username: \(newUsername), Profile Image: \(newProfileImage)")
                        
                        DispatchQueue.main.async {
                            self.comment.profileIamge = newProfileImage
                            self.comment.username = newUsername
                        }
                    }
                }
            }
            
        }
        
        
    }
}


//#Preview {
//    CommentCard()
//}

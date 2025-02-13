import SwiftUI
import SDWebImageSwiftUI

struct Search: View {
    
    @State private var value = ""
    @State private var users = [UserModel]()
    @State  var isLoading = false
    
    func searchUsers() {
        isLoading = true
        
        SearchService.searchUser(input: value) { user in
            self.isLoading = false
            self.users = user
        }
    }// searchUsers
    
    var body: some View {
        
        NavigationStack{
            
            ScrollView{
                
                VStack(alignment: .leading){
                    
                    SearchBar(value: $value)
                        .padding(.vertical)
                        .onChange(of: value) {
                            searchUsers()
                        }
                    
                    if !isLoading {
                        
                        ForEach(users, id: \.uId) { user in
                            
                            NavigationLink(destination: UserProfileView(user: user)) {
                                
                                HStack(spacing: -10){
                                    
                                    WebImage(url: URL(string: user.profileImageUrl)) { image in image
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(.circle)
                                            .frame(width: 70, height: 70, alignment: .trailing)
                                            .padding()
                                        
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 55, height: 55)
                                    }
                                    
                                    VStack(spacing: -1.5){
                                        
                                        Text("\(user.username)")
                                        
                                    }// VStack
                                    
                                }// HStack
                                
                                //                            Divider().background(Color.black)
                                
                            }
                            
                        }// ForEach
                    }
                    
                }// VStack
                
            }// ScrollView
            .navigationTitle("Search")
            
        }// NavigationStack
        
    }
}

#Preview {
    Search()
}

import SwiftUI

struct SearchBar: View {
    
    @Binding  var value: String
    @State  var isSearching = false
    
    var body: some View {
        
        HStack {
            
            TextField("Search users here", text: $value)
                .padding(.leading, 24)
            
        }// HStack
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal)
        .onTapGesture {
            isSearching = true
        }
        .overlay(
            HStack{
                Image(systemName: "magnifyingglass")
                
                Spacer()
                
                Button {
                    value = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
                .foregroundColor(.gray)
                .padding(.horizontal, 32)
        )
    }
}

//#Preview {
//    SearchBar()
//}

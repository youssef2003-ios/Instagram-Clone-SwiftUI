import SwiftUI

struct Notifications: View {
    
    var body: some View {
       
        NavigationStack{
            
            VStack{
                
                Image(systemName: "bell.and.waves.left.and.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 65)
                
            }
            .navigationTitle("Notifications")
            
        }// NavigationStack
            
    }
}

#Preview {
    Notifications()
}

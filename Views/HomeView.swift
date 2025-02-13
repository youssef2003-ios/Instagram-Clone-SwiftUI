import SwiftUI

struct HomeView: View {
    
    
    var body: some View {
        
        TabView{
            
            Main()
                .tabItem {
                    Image(systemName: "house")
                }
            
            Search()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            
            Post()
                .tabItem {
                    Image(systemName: "plus.square")
                }
            
            Notifications()
                .tabItem {
                    Image(systemName: "heart")
                }
            
            Profile()
                .tabItem {
                    Image(systemName: "person")
                }
            
        }// TabView
        .accentColor(.accent)
        
    }
}




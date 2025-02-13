import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State private var isLoading = true  // Show loading initially

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .scaleEffect(2)
            } else {
                if session.session != nil {
                    HomeView()  // User is authenticated
                } else {
                    SignInView()  // User is NOT authenticated
                }
            }
        }
        .onAppear {
            session.listen {
                DispatchQueue.main.async {
                    isLoading = false  // Stop showing loading
                }
            }
        }
    }
}




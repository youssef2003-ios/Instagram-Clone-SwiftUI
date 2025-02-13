import SwiftUI
import Foundation
import Combine
import Firebase
import FirebaseAuth


class SessionStore: ObservableObject {
    
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var session: UserModel? {didSet{self.didChange.send(self)}}
    var handle: AuthStateDidChangeListenerHandle?
    
    
    /// Listens to Firebase authentication state changes
    func listen(completion: @escaping () -> Void) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                let firestoreUserId = AuthService.getUserId(userId: user.uid)
                firestoreUserId.getDocument { document, error in
                    if let dict = document?.data() {
                        DispatchQueue.main.async {
                            self.session = try? UserModel(fromDictionary: dict)
                            completion()  // Notify that session is loaded
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.session = nil
                            completion()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.session = nil
                    completion()
                }
            }
        }
    }
    
    /// Signs out the user and clears the session
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.session = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    /// Stops listening for authentication changes
    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
            self.handle = nil  // Avoid potential memory leaks
        }
    }
    
    /// Ensures listener is unbound when this instance is deallocated
    deinit {
        unbind()
    }
    
    func loadCurrentUser() {
        if let userId = Auth.auth().currentUser?.uid {
            AuthService.storeRoot.collection("users").document(userId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    DispatchQueue.main.async {
                        self.session = try? UserModel(fromDictionary: data)
                    }
                }
            }
        }
    }// loadCurrentUser
    
    
}// SessionStore

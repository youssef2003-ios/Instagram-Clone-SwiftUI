import SwiftUI

struct FormField: View {
    //Properties
    
    @Binding var value: String
    
    @State var icon: String
    @State var placeholder: String
    @State var isScure: Bool = false
    
    //Body
    var body: some View {
        
        Group {
            
            HStack{
                
                Image(systemName: icon)
                    .padding()
                
                Group {
                    
                    if isScure {
                        SecureField(placeholder, text: $value)
                    } else {
                        TextField(placeholder, text: $value)
                    }
                    
                }// Group2
                .font(.system(size: 20, design: .monospaced))
                .foregroundStyle(Color.black)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.leading)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                 
            }// HStack
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 3)
            )
      
        }// Group1
        
        
        
        
    }
}

//#Preview {
//    FormField(icon: "")
//}

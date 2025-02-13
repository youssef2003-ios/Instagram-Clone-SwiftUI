import SwiftUI

struct ButtonModifiers: ViewModifier {
    
    var background: Color?
    var foregroundColor: Color
    var width: CGFloat?
    var height: CGFloat
    var fontSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: width == nil ? .infinity : width)
            .frame(height: height)
            .padding()
            .foregroundStyle(foregroundColor)
            .font(.system(size: fontSize, weight: .bold))
            .background(background)
            .cornerRadius(10)
    }
}

//#Preview {
//    ButtonModifiers()
//}

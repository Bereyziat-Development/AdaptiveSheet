import SwiftUI

@available(iOS 15, *)
extension View {
    public func adaptiveHeightSheet<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        
        return fullScreenCover(isPresented: isPresented) {
            AdapatativeSheetView(content: content)
                .background(TransparentView())
                    }
        }
}
@available(iOS 15, *)
public struct AdapatativeSheetView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var content: () -> Content
    @State private var opacity: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isContentDisplayed: Bool = false
    
    public init(@ViewBuilder content: @escaping () -> Content) {
           self.content = content
       }
    
    public var body: some View {
        ZStack {
            Color(.black)
                .opacity(opacity)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onTapGesture {
                    dismiss()
                }
            VStack {
                Spacer()
                if isContentDisplayed {
                    content()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                        .padding(.top, 20)
                        .background(Rectangle()
                            .fill(Color.white)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        )
                        .transition(.move(edge: .bottom))
                        .offset(y: offset)
                }
                
            }
        }
        .gesture(DragGesture()
            .onChanged { offset = $0.translation.height }
            .onEnded { value in
                if value.translation.height > 200 {
                    dismiss()
                }
                else {
                    withAnimation(.spring(response: 0.5)) {
                        offset = 0.0
                    }
                }
            })
        .onAppear {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = 0.6
                }
                withAnimation(.spring(response: 0.6)) {
                    isContentDisplayed.toggle()
                }
                offset = 0.0
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.5)) {
                opacity = 0.0
            }
            withAnimation(.spring(response: 0.6)) {
                isContentDisplayed.toggle()
            }
        }
    }
}
@available(iOS 15, *)
fileprivate struct TransparentView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
//EXAMPLE
@available(iOS 15, *)
fileprivate struct ExampleView: View {
    @State var showCover = false
    
    var body: some View {
        VStack {
            Button("Test") {
                showCover.toggle()
            }
            .adaptiveHeightSheet(isPresented: $showCover)
            {
                VStack(alignment: .leading) {
                    Button("Close") {
                        showCover.toggle()
                    }
                    Text("And a bit of text for this view")
                    Text("And a bit more text to verify if the size of the view adapts to the conent")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

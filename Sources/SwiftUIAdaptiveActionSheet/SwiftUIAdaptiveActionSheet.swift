import SwiftUI

@available(iOS 15, *)
public extension View {
    func adaptiveHeightSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        sheetBackgroundColor: Color = .white,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        return fullScreenCover(
            isPresented: isPresented,
            onDismiss: onDismiss
        ) {
            AdapatativeSheetView(sheetBackgroundColor: sheetBackgroundColor, content: content)
                .background(TransparentView())
        }
    }
}

@available(iOS 15, *)
public struct AdapatativeSheetView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var content: () -> Content
    private var sheetBackgroundColor: Color
    private var backgroundOpacity: CGFloat = 0.6
    @State private var bottomHiddenPadding: CGFloat = 0
    @State private var opacity: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isContentDisplayed: Bool = false
    
    //MARK: Constants
    private let maxAllowedUpwardOffset: CGFloat = 50
    private let minTranslationToDismiss: CGFloat = 200
    
    public init(sheetBackgroundColor: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.sheetBackgroundColor = sheetBackgroundColor
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            Color(.black)
                .opacity(opacity)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .onTapGesture {
                    animatedDismiss()
                }
            VStack {
                Spacer()
                if isContentDisplayed {
                    content()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                        .padding(.top, 20)
                        .padding(.bottom, bottomHiddenPadding)
                        .background(Rectangle()
                            .fill(sheetBackgroundColor)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                        )
                        .transition(.move(edge: .bottom))
                        .offset(y: bottomHiddenPadding)
                        .offset(y: offset)
                }
            }
        }
        .gesture(
            DragGesture()
            .onChanged {
                if $0.translation.height > 0 {
                    offset = $0.translation.height
                } else {
                    offset = $0.translation.height/sqrt(-$0.translation.height)
                }
                if offset < 0 {
                    bottomHiddenPadding = -offset + 10
                }
            }
            .onEnded { value in
                if value.translation.height > minTranslationToDismiss {
                    animatedDismiss()
                } else {
                    withAnimation(.spring(response: 0.5)) {
                        offset = 0.0
                    }
                }
            })
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    opacity = backgroundOpacity
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                isContentDisplayed.toggle()
            }
            offset = 0.0
        }
    }
    private func animatedDismiss() {
        withAnimation(.easeInOut(duration: 0.5)) {
            opacity = 0.0
        }
        withAnimation(.spring(response: 0.5)) {
            isContentDisplayed.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

@available(iOS 15, *)
private struct TransparentView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// EXAMPLE

@available(iOS 15, *)
private struct ExampleBody: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading) {
            Button("Close") {
                dismiss()
            }
            Text("And a bit of text for this view")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            Text("And a bit more text to verify if the size of the view adapts to the conent")
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 40)
        .padding(.top, 20)
    }
}
@available(iOS 15, *)
private struct ExampleView: View {
    @State var showCover = false
    @State var showCoverWithBackground = false
    @State var showNativeSheet = false
    
    var body: some View {
        VStack {
            Button("Open sheet") {
                showCover.toggle()
            }
            .buttonStyle(.bordered)
            Button("Open sheet with background") {
                showCoverWithBackground.toggle()
            }
            .buttonStyle(.bordered)
            Button("Open native sheet") {
                showNativeSheet.toggle()
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showNativeSheet) {
            Text("Nice sheet but we can do better 😉")
        }
        .adaptiveHeightSheet(isPresented: $showCover) {
            ExampleBody()
        }
    }
}

#Preview {
    ExampleView()
}

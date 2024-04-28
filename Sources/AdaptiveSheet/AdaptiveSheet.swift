import SwiftUI

@available(iOS 15, *)
public extension View {
    func adaptiveSheet<Content: View, Background: ShapeStyle>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        sheetBackground: Background = Color(UIColor.systemBackground),
        backgroundOpacity: CGFloat = 0.6,
        shadow: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        return fullScreenCover(
            isPresented: isPresented,
            onDismiss: onDismiss
        ) {
            AdapatativeSheetView(
                isPresented: isPresented,
                sheetBackground: sheetBackground,
                backgroundOpacity: backgroundOpacity,
                shadow: shadow,
                content: content
            )
            .background(TransparentView())
        }
    }
}

@available(iOS 15, *)
public struct AdapatativeSheetView<Content: View, Background: ShapeStyle>: View {
    @Environment(\.adaptiveDismiss) private var adaptiveDismiss
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder private var content: () -> Content
    @Binding private var isPresented: Bool
    private var sheetBackground: Background
    private var backgroundOpacity: CGFloat
    private var shadow: Bool
    @State private var bottomPadding: CGFloat = 80
    @State private var opacity: CGFloat = 0.0
    @State private var offset: CGFloat = 0.0
    @State private var isContentDisplayed = false
    @State private var isDismissing = false

    // MARK: Constants

    private let initialBottomPadding: CGFloat = 80
    private let minTranslationToDismiss: CGFloat = 200

    public init(
        isPresented: Binding<Bool>,
        sheetBackground: Background = Color(UIColor.systemBackground),
        backgroundOpacity: CGFloat = 0.6,
        shadow: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.sheetBackground = sheetBackground
        self.backgroundOpacity = backgroundOpacity
        self.shadow = shadow
        self.content = content
    }

    public var body: some View {
        ZStack {
            Color(.black)
                .opacity(opacity)
                .ignoresSafeArea()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .onTapGesture {
                    animatedDismiss()
                }
            VStack {
                Spacer()
                if isContentDisplayed {
                    content()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, bottomPadding)
                        .padding(.vertical, 20)
                        .background(
                            Rectangle()
                                .fill(sheetBackground)
                                .frame(maxWidth: .infinity)
                                .clipShape(
                                    RoundedCorner(
                                        radius: 20,
                                        corners: [.topLeft, .topRight]
                                    )
                                )
                                .shadow(
                                    color: .black.opacity(
                                        shadow ? 0.2 : 0
                                    ),
                                    radius: 15,
                                    x: 0, y: 4
                                )
                        )
                        .transition(.move(edge: .bottom))
                        .offset(y: bottomPadding)
                        .offset(y: offset)
                }
            }
        }
        .adaptiveDismissHandler {
            animatedDismiss()
        }
        .gesture(
            DragGesture()
                .onChanged {
                    if $0.translation.height >= 0 {
                        offset = $0.translation.height
                    } else {
                        offset = $0.translation.height / sqrt(-$0.translation.height)
                    }
                    if offset < 0 {
                        bottomPadding = -offset + initialBottomPadding
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
            withAnimation(.spring(response: 0.8)) {
                isContentDisplayed.toggle()
            }
        }
    }

    private func animatedDismiss() {
        //Make sure that the animation cannot get triggered twice
        guard !isDismissing else { return }
        isDismissing = true
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

//MARK: Example
@available(iOS 15, *)
private struct ExampleBody: View {
    @Environment(\.adaptiveDismiss) private var adaptiveDismiss
    var body: some View {
        VStack(alignment: .leading) {
            Button("Close") {
                adaptiveDismiss()
            }
            Text("And a bit of text for this view")
            Text("And a bit more text to verify if the size of the view adapts to the content")
            Text("And a bit more text to verify if the size of the view adapts to the content")
            Text("And a bit more text to verify if the size of the view adapts to the content")
            Text("And a bit more text to verify if the size of the view adapts to the content")
            Text("And a bit more text to verify if the size of the view adapts to the content")
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
        .adaptiveSheet(
            isPresented: $showCover,
            sheetBackground: Material.ultraThinMaterial,
            backgroundOpacity: 0.0,
            shadow: false
        ) {
            ExampleBody()
        }
        .adaptiveSheet(
            isPresented: $showCoverWithBackground
        ) {
            ExampleBody()
        }
    }
}

#Preview {
    ExampleView()
}

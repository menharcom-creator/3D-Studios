import SwiftUI
import WebKit

@main
struct StudioApp: App {
    var body: some Scene {
        WindowGroup { StudioWebView().ignoresSafeArea().background(Color.black) }
    }
}

struct StudioWebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.userContentController.add(context.coordinator, name: "share")
        let w = WKWebView(frame: .zero, configuration: cfg)
        w.scrollView.bounces = false
        w.isOpaque = false
        w.backgroundColor = .black
        if let u = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") {
            w.loadFileURL(u, allowingReadAccessTo: u.deletingLastPathComponent())
        }
        return w
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
            guard let d = m.body as? [String: String], let name = d["name"], let text = d["data"] else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try? text.write(to: url, atomically: true, encoding: .utf8)
            DispatchQueue.main.async {
                guard let root = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController else { return }
                let v = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                v.popoverPresentationController?.sourceView = root.view
                v.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 1, height: 1)
                root.present(v, animated: true)
            }
        }
    }
}

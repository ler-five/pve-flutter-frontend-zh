import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel: FlutterMethodChannel = FlutterMethodChannel(
            name: "com.proxmox.app.pve_flutter_frontend/filesharing",
            binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

            guard call.method == "shareFile" else {
                result(FlutterMethodNotImplemented)
                return
            }

            let arguments = call.arguments as? [String: Any]
            let path = arguments?["path"] as? String
            let type = arguments?["type"] as? String

            if let filePath = path, let _ = type  {
                self?.shareFile(atPath: filePath, from: controller, result: result)
            } else {
                result(FlutterError(code: "FileNotFoundException", message: "File not found", details: nil))
            }
        })

        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func shareFile(atPath path: String, from controller: UIViewController, result: @escaping FlutterResult) {
        let fileURL = URL(fileURLWithPath: path)
        let activityVC = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil,
        )

        // To avoid crashing in iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(
                x: controller.view.bounds.midX,
                y: controller.view.bounds.midY,
                width: 0,
                height: 0,
            )
        }

        controller.present(activityVC, animated: true) {
            result(nil)
        }
    }
}

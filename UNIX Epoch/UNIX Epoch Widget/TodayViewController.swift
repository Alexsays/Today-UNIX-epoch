//
// UNIX Epoch
//
// Alexsays - 2019
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {

    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var msCheck: NSButton!
    @IBOutlet weak var copyButton: NSButton!

    let copiedView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(white: 0, alpha: 0.8).cgColor
        view.layer?.cornerRadius = 10
        view.alphaValue = 0
        return view
    }()

    let copiedLabel: NSTextField = {
        let label = NSTextField(labelWithString: "Copied to\nclipboard")
        label.font = NSFont.boldSystemFont(ofSize: 20)
        label.maximumNumberOfLines = 0
        label.alignment = .center
        return label
    }()

    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        datePicker.delegate = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        datePicker.dateValue = Date()
        timeLabel.stringValue = String(format: "%.0f", Date().timeIntervalSince1970)
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }

    // MARK: UI methods

    private func setupUI() {
        copiedView.translatesAutoresizingMaskIntoConstraints = false
        copiedLabel.translatesAutoresizingMaskIntoConstraints = false
        copiedView.addSubview(copiedLabel)
        view.addSubview(copiedView)

        copiedView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        copiedView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        copiedView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        copiedView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        copiedLabel.centerXAnchor.constraint(equalTo: copiedView.centerXAnchor).isActive = true
        copiedLabel.centerYAnchor.constraint(equalTo: copiedView.centerYAnchor).isActive = true
    }

    // MARK: Actions

    @IBAction func copyClicked(_ sender: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(timeLabel.stringValue, forType: .string)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25

            copiedView.animator().alphaValue = 1.0
        }) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.25
                    
                    self.copiedView.animator().alphaValue = 0.0
                })
            })
        }
    }

    @IBAction func checkClicked(_ sender: NSButton) {
        guard let time = Int(timeLabel.stringValue) else { return }
        switch msCheck.state {
        case .on:
            timeLabel.stringValue = String(time * 1000)
        case .off:
            timeLabel.stringValue = String(time / 1000)
        default:
            break
        }
    }

}

private typealias DateMethods = TodayViewController
extension DateMethods: NSDatePickerCellDelegate {

    func datePickerCell(_ datePickerCell: NSDatePickerCell, validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate>, timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?) {
        switch msCheck.state {
        case .on:
            timeLabel.stringValue = String(format: "%.0f", datePickerCell.dateValue.timeIntervalSince1970 * 1000)
        case .off:
            timeLabel.stringValue = String(format: "%.0f", datePickerCell.dateValue.timeIntervalSince1970)
        default:
            break
        }
    }

}

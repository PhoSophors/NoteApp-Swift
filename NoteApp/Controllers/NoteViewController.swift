import UIKit
import SnapKit

class NoteViewController: UIViewController, UITextViewDelegate {

    // MARK: - Properties

    var selectedNote: Note?
    var folder: Folder? // Assuming you pass the folder object to display the note

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.tintColor = ColorManager.shared.nightRiderColor()
        textField.textColor = ColorManager.shared.nightRiderColor()
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.layer.borderWidth = 0
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        
        // Set height constraint
        textField.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        return textField
    }()


    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = ColorManager.shared.backgroundColor()
        textView.tintColor = ColorManager.shared.nightRiderColor()
        textView.textColor = ColorManager.shared.nightRiderColor()
        textView.layer.cornerRadius = 15
        textView.layer.masksToBounds = true
        textView.textAlignment = .left
        textView.delegate = self
        
        // Set content inset for padding
        let padding: CGFloat = 10
        textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)

        return textView
    }()



    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNoteChanges))
        return button
    }()

    private var keyboardHeight: CGFloat = 0.0
    var noteUpdatedCallback: (() -> Void)?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Update Note"
        view.backgroundColor = ColorManager.shared.backgroundColor()
        
        setupConstraints()
        setupKeyboardObservers()
        displayNoteDetails()

        navigationItem.rightBarButtonItem = saveButton
    }

    // MARK: - UI Setup and Constraints

    private func setupConstraints() {
        // Add titleTextField
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(0)
        }

        // Add descriptionTextView
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.equalTo(view.snp.bottom)
        }
    }

    // MARK: - Data Handling

    private func displayNoteDetails() {
        if let note = selectedNote {
            titleTextField.text = note.noteTitle
            descriptionTextView.text = note.noteDescription
        }
    }

    @objc private func saveNoteChanges() {
        guard let updatedTitle = titleTextField.text, !updatedTitle.isEmpty,
              let updatedDescription = descriptionTextView.text, !updatedDescription.isEmpty,
              let note = selectedNote else {
            showErrorMessage("Title or description cannot be empty.")
            return
        }

        DataManager.shared.updateNote(note: note, withTitle: updatedTitle, description: updatedDescription)

        // Update the selected note object with new data
        selectedNote?.noteTitle = updatedTitle
        selectedNote?.noteDescription = updatedDescription

        // Invoke the callback to notify that a note has been updated
        noteUpdatedCallback?()

        // Show success alert
        let alertController = UIAlertController(title: "Success", message: "Note updated successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            // Navigate back to FolderDetailViewController
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        descriptionTextView.contentInset = contentInsets
        descriptionTextView.scrollIndicatorInsets = contentInsets
        
        // Adjust the scroll view's content offset if needed
        var visibleRect = view.frame
        visibleRect.size.height -= keyboardHeight
        
        if descriptionTextView.isFirstResponder {
            let activeFieldRect = CGRect(origin: CGPoint(x: 0, y: descriptionTextView.frame.origin.y),
                                         size: CGSize(width: descriptionTextView.frame.size.width,
                                                      height: descriptionTextView.frame.size.height))
            
            if !visibleRect.contains(activeFieldRect.origin) {
                descriptionTextView.scrollRectToVisible(activeFieldRect, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    // MARK: - Error Handling

    private func showErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Memory Management

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

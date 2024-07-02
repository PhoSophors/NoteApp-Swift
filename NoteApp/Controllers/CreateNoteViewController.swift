import UIKit
import SnapKit

protocol CreateNoteViewControllerDelegate: AnyObject {
    func didCreateNote()
}

class CreateNoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    var selectedFolder: Folder?
    private let dataManager = DataManager.shared
    weak var delegate: CreateNoteViewControllerDelegate?
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter title"
        textField.tintColor = ColorManager.shared.nightRiderColor()
        textField.textColor = ColorManager.shared.nightRiderColor()
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.layer.cornerRadius = 0
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.darkGray.cgColor

        // Set placeholder text with bold and size 24 attributes
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter title",
            attributes: [
                NSAttributedString.Key.foregroundColor: ColorManager.shared.nightRiderColor(),
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
        )
        
        let padding: CGFloat = 15
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: textField.frame.height)) // Optional: Add left padding
        textField.leftViewMode = .always

        return textField
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Enter description"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = ColorManager.shared.backgroundColor()
        textView.tintColor = ColorManager.shared.nightRiderColor()
        textView.textColor = ColorManager.shared.nightRiderColor()
        textView.layer.masksToBounds = true
        textView.textAlignment = .left
        
        let padding: CGFloat = 10
        textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        
        return textView
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        return button
    }()
    
    // Callback closure to notify when a note is created
    var noteCreatedCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorManager.shared.backgroundColor()
        title = "Create Note"
        
        setupUI()
        
        // Assign UITextViewDelegate to descriptionTextView
        descriptionTextView.delegate = self
        titleTextField.delegate = self
        
        navigationItem.rightBarButtonItem = saveButton
        
        // Setup keyboard observers
        setupKeyboardObservers()
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(0)
            make.height.equalTo(40)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(0)
            make.leading.trailing.equalToSuperview().inset(00)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              let folder = selectedFolder else {
            showErrorMessage("Title, description, or folder cannot be empty.")
            return
        }
        
        // Save the note using DataManager
        dataManager.saveNote(title: title, description: description, folder: folder)
        
        // Notify delegate or callback that a note has been created
        noteCreatedCallback?()
        
        // Show success message and dismiss
        showSuccessMessage()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
        descriptionTextView.contentInset = .zero
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter description" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description"
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func showSuccessMessage() {
        let alertController = UIAlertController(title: "Success", message: "Note created successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            // Dismiss this view controller
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
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

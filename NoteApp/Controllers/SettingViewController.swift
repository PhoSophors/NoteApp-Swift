import UIKit
import SnapKit

class SettingViewController: UIViewController {

    var username: String?
    
    // UI elements
    private let personIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = ColorManager.shared.nightRiderColor()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorManager.shared.nightRiderColor()
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: button.titleLabel?.font.pointSize ?? 17) // Use current size or default
        ]
        let attributedTitle = NSAttributedString(string: "Sign Out", attributes: attributes)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        
        return button
    }()
    
    let formBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.shared.backgroundColor()
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 5
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        view.backgroundColor = ColorManager.shared.backgroundColor()
        
        // Add formBackgroundView to the main view
        view.addSubview(formBackgroundView)
        
        // Add subviews to formBackgroundView
        formBackgroundView.addSubview(personIconImageView)
        formBackgroundView.addSubview(usernameLabel)
        formBackgroundView.addSubview(logoutButton)
        
        setupUI()
        
        // Check if user is logged in and update usernameLabel
        updateUsernameLabel()
    }

    // MARK: - Private Functions
    
    // Function to setup UI elements and their constraints
    private func setupUI() {
        // Setup constraints for formBackgroundView using SnapKit
        formBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(logoutButton.snp.bottom).offset(20)
        }
        
        // Setup constraints for personIconImageView
        personIconImageView.snp.makeConstraints { make in
            make.top.equalTo(formBackgroundView).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        // Setup constraints for usernameLabel
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(personIconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(formBackgroundView).offset(20)
            make.trailing.lessThanOrEqualTo(formBackgroundView).offset(-20)
        }
        
        // Setup constraints for logoutButton
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(20)
            make.leading.trailing.equalTo(formBackgroundView).inset(20)
            make.height.equalTo(40)
            make.bottom.equalTo(formBackgroundView).offset(-20)
        }
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            // Clear login state and Core Data
            LoginHelper.clearLoginState()
//            DataManager.shared.clearCoreData()
            
            // Dismiss current view controller
            self.dismiss(animated: true, completion: nil)
            
            // Present the login screen again
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showLoginScreen()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }


    // Function to update usernameLabel with the current logged-in username
    private func updateUsernameLabel() {
        LoginHelper.checkLoginStatus { isLoggedIn, username in
            if isLoggedIn, let username = username {
                DispatchQueue.main.async {
                    let attributedText = NSAttributedString(string: username, attributes: [
                        .font: UIFont.boldSystemFont(ofSize: 24),
                        .foregroundColor: UIColor.black // Adjust color as needed
                    ])
                    self.usernameLabel.attributedText = attributedText
                }
            }
        }
    }

}

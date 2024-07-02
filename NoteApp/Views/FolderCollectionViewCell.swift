import UIKit
import SnapKit

class FolderCollectionViewCell: UICollectionViewCell {

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ColorManager.shared.nightRiderColor()
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    let noteCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = ColorManager.shared.nightRiderColor()
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create blurred background view
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(blurEffectView)
        
        // Apply constraints for blurEffectView
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        // Create white mask view to overlay on top of blur
        let maskView = UIView()
        maskView.backgroundColor = .white
        maskView.alpha = 0.8 // Adjust opacity as needed
        maskView.layer.cornerRadius = 15
        maskView.layer.masksToBounds = true
        blurEffectView.contentView.addSubview(maskView)
        
        // Apply constraints for maskView
        maskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Add folder icon
        let folderImageView = UIImageView(image: UIImage(systemName: "folder.fill"))
        folderImageView.tintColor = ColorManager.shared.nightRiderColor()
        folderImageView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.contentView.addSubview(folderImageView)
        
        // Apply constraints for folderImageView
        folderImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(50)
        }
        
        // Add nameLabel and noteCountLabel to blurEffectView's contentView
        blurEffectView.contentView.addSubview(nameLabel)
        blurEffectView.contentView.addSubview(noteCountLabel)
        
        // Set colors using ColorManager or directly as needed
        nameLabel.textColor = ColorManager.shared.nightRiderColor()
        noteCountLabel.textColor = .darkGray

        // Apply constraints for nameLabel
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(folderImageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        // Apply constraints for noteCountLabel
        noteCountLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }



    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

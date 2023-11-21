//
//  TestCell.swift
//  SampleProject_CollectionView
//
//  Created by Ari on 2023/11/21.
//

import UIKit

final class TestCell: UICollectionViewCell {
    
    private weak var containerView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupLayoutConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let containerView = UIView()
        containerView.backgroundColor = .systemBlue
        contentView.addSubview(containerView)
        self.containerView = containerView
    }
    
    private func setupLayoutConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    enum Const {
        static let ratio: CGFloat = 315 / 513
        static var size: CGSize {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: 315, height: 513)
            } else {
                let parentViewSize = ViewController.Const.size
                let width = parentViewSize.width - 60
                let height = parentViewSize.height - 100
                return CGSize(width: width, height: height)
            }
        }
    }
}

//
//  ViewController.swift
//  SampleProject_CollectionView
//
//  Created by Ari on 2023/11/21.
//

import UIKit

typealias DemoDataSource = UICollectionViewDiffableDataSource<ViewController.Section, ViewController.Item>
typealias DemoSnapshot = NSDiffableDataSourceSnapshot<ViewController.Section, ViewController.Item>

class ViewController: UIViewController {
    
    private weak var collectionView: UICollectionView!
    private var dataSource: DemoDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayoutConstraints()
        setupDataSource()
        
        let list = [UUID(), UUID(), UUID(), UUID(), UUID()]
        let items = list.map { Item.empty($0) }
        applySnapshot([CellModel(section: .main, items: items)])
    }


    private func setupViews() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(TestCell.self, forCellWithReuseIdentifier: "\(TestCell.self)")
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
    }
    
    private func setupLayoutConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let width = UIScreen.main.bounds.width
        let ratio: CGFloat = 375 / 614
        let height = ceil(width / ratio)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: (width - height)),
        ])
    }
    
    private func setupDataSource() {
        dataSource = DemoDataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            switch item {
            case .empty:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TestCell.self)", for: indexPath) as! TestCell
                return cell
            }
        })
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionNumber, _ -> NSCollectionLayoutSection? in
            guard let section = self?.dataSource?.sectionIdentifier(for: sectionNumber) else {
                return nil
            }
            switch section {
            case .main: return self?.mainSectionLayout()
            }
        }
        return layout
    }
    
    private func mainSectionLayout() -> NSCollectionLayoutSection? {
        let itemSideMargin: CGFloat = 15
        let itemWidth = TestCell.Const.size.width + itemSideMargin
        let sectionTrailingMargin: CGFloat = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return UIScreen.main.bounds.width - (itemWidth + itemSideMargin)
            } else {
                return 30
            }
        }()
        let itemSize = NSCollectionLayoutSize(
            /// inset을 추가하면 해당 inset 만큼 width가 줄어들기 때문에 inset 값을 더함.
            widthDimension: .absolute(itemWidth),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: .zero, leading: itemSideMargin, bottom: .zero, trailing: .zero)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: itemSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        /// section의 inset 또한 item의 inset 만큼 줄어들기 때문에 item inset을 더함.
        section.contentInsets = .init(top: .zero, leading: itemSideMargin, bottom: .zero, trailing: sectionTrailingMargin)
        section.orthogonalScrollingBehavior = UIDevice.current.userInterfaceIdiom == .pad ? .groupPaging : .groupPagingCentered
        return section
    }
    
    private func applySnapshot(_ cellModels: [CellModel], animated: Bool = true) {
        var snapshot = DemoSnapshot()
        cellModels.forEach {
            snapshot.appendSections([$0.section])
            snapshot.appendItems($0.items)
        }
        dataSource?.apply(snapshot, animatingDifferences: animated)
    }
    
    enum Const {
        static let ratio: CGFloat = 375 / 614
        static var size: CGSize {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: UIScreen.main.bounds.width, height: 614)
            } else {
                let width = UIScreen.main.bounds.width
                let height = ceil(width / ratio)
                return CGSize(width: width, height: height)
            }
        }
    }
}

// MARK: - Diffable Data Source Section type
extension ViewController {

    struct CellModel: Hashable {

        let section: Section
        var items: [Item]

        func hash(into hasher: inout Hasher) {
            hasher.combine(section)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.section == rhs.section
        }
    }

    enum Section {
        case main
    }

    enum Item: Hashable, Equatable {

        case empty(UUID)

        func hash(into hasher: inout Hasher) {
            switch self {
            case let .empty(id):
                hasher.combine(id)
            }
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            switch (lhs, rhs) {
            case let (.empty(lhs), .empty(rhs)):
                return lhs == rhs
            }
        }
    }
}

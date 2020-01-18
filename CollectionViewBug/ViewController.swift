//
//  ViewController.swift
//  CollectionViewBug
//
//  Created by David Everlöf on 2020-01-18.
//  Copyright © 2020 David Everlöf. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var collectionView: CollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = CollectionView()
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .red
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.fetch()
    }

}

class MyCell: UICollectionViewCell {
    
    static let identifier = "MyCell"
    
    var test: Test?
    
    let btn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        btn.setTitle("test", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(doAction), for: .touchUpInside)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(btn)
        contentView.backgroundColor = .white
        
        btn.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        btn.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doAction() {
        print("Action from cell \(self)")
        let testID = test!.objectID
        AppDelegate.persistentContainer.performBackgroundTask { ctx in
            let test = ctx.object(with: testID) as! Test
            test.a = UUID().uuidString
            try! ctx.save()
        }
    }
    
    func update(test: Test) {
        self.test = test
        print("update(test:) -> \(self)")
    }
    
}

class CollectionView: UICollectionView, NSFetchedResultsControllerDelegate, UICollectionViewDelegate {

    let fetchResultController: NSFetchedResultsController<Test>

    var diffableDataSource: UICollectionViewDiffableDataSourceReference!
    
    init() {
        let fetchRequest: NSFetchRequest<Test> = Test.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Test.a, ascending: true)]
        fetchResultController = NSFetchedResultsController<Test>(fetchRequest: fetchRequest,
                                                                  managedObjectContext: AppDelegate.persistentContainer.viewContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(MyCell.self, forCellWithReuseIdentifier: MyCell.identifier)
        diffableDataSource =
            UICollectionViewDiffableDataSourceReference(collectionView: self, cellProvider: { collectionView, indexPath, testID in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCell.identifier, for: indexPath) as! MyCell
                let test = AppDelegate.persistentContainer.viewContext.object(with: testID as! NSManagedObjectID) as! Test
                cell.update(test: test)
                print("Requrning dequeued => \(cell)")
                return cell
            }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetch() {
        delegate = self
        dataSource = diffableDataSource
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        diffableDataSource.applySnapshot(snapshot, animatingDifferences: true)
    }
    
}

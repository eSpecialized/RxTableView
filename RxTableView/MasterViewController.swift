//
//  MasterViewController.swift
//  RxTableView
//
//  Created by William Thompson on 5/27/18.
//  Copyright © 2018 William Thompson. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    let bag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String,String>>!
    //var dataEmitter = BehaviorSubject(value: [SectionModel(model: "Position", items: ["1st", "2nd", "3rd"])] )
    var dataEmitter = ReplaySubject<[SectionModel<String,String>]>.create(bufferSize: 1)
    
    var trackedItems = ["1st", "2nd", "3rd","4th"]
    var dataModel = SectionModel(model: "Position", items: [String]())
    
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true

        addButton.rx.tap.bind { [weak self] in
            guard let sself = self else { return }
            print("Tapped")
            sself.trackedItems.append("This And That")
            sself.dataModel.items = sself.trackedItems
            sself.dataEmitter.onNext([sself.dataModel])
            }
            .disposed(by: bag)
        
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.dataSource = nil
        
        dataModel.items = trackedItems
        dataEmitter.onNext([dataModel])
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,String>>(configureCell: { (dataSrc: TableViewSectionedDataSource , table: UITableView, indexPath: IndexPath, itemIn )  in
            
            let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            cell.textLabel?.text = itemIn
            
            return cell
        })
        
        dataSource.titleForHeaderInSection = { (dataSrc, index) in
            return dataSrc.sectionModels[index].model
        }
        
        dataEmitter
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        
        self.rx.sentMessage(#selector(prepare(for:sender:)))
            .subscribe(onNext: { [weak self] items in
                print("prepare For Segue")
                if let segue = items.first as? UIStoryboardSegue {
                    print("Segue \(segue.identifier!)")
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                        if let object = self?.dataModel.items[indexPath.row] {
                            controller.publishDetail.onNext(object)
                        }
                        controller.navigationItem.leftBarButtonItem = self?.splitViewController?.displayModeButtonItem
                        controller.navigationItem.leftItemsSupplementBackButton = true
                    }
                }
                
            })
            .disposed(by: bag)
        
        self.rx.sentMessage(#selector(didReceiveMemoryWarning))
            .subscribe(onNext: { Void in
                super.didReceiveMemoryWarning()
                print("didReceiveMemoryWarning")
            })
            .disposed(by: bag)
        
        self.rx.sentMessage(#selector(viewWillAppear(_:)))
            .subscribe(onNext: { values in
                if let animated = values.first as? Bool {
                    super.viewWillAppear(animated)
                }
            })
            .disposed(by: bag)
    }

}


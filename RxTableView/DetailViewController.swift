//
//  DetailViewController.swift
//  RxTableView
//
//  Created by William Thompson on 5/27/18.
//  Copyright © 2018 William Thompson. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var publishDetail = BehaviorSubject<String>(value: "")
    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishDetail
            .bind(to: detailDescriptionLabel.rx.text)
            .disposed(by: bag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


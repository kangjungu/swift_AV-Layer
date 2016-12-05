//
//  ViewController.swift
//  TmapTest
//
//  Created by JHJG on 2016. 11. 21..
//  Copyright © 2016년 KangJungu. All rights reserved.
//

//https://developers.skplanetx.com/develop/doc/sdk/open-api/ios-tutorial/ : 프로젝트 만드는 설명
//https://developers.skplanetx.com/develop/doc/sdk/open-api/ios-reference/ : api 설명

import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func button(_ sender: AnyObject) {
        print(view.bounds)
        var map = TMapView(frame: view.bounds)
        map.setSKPMapApiKey("4378c124-0074-36f0-9680-120df26398b4")
        view.addSubview(map);
        
    }


    
        
}


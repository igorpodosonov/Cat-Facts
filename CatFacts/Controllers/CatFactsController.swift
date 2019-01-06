//
//  CatFactsController.swift
//  CatFacts
//
//  Created by Игорь on 06/01/2019.
//  Copyright © 2019 Igor Podosonov. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftyJSON
import SCLAlertView
import Alamofire

class CatFactsController: UITableViewController {

    let CATS_URL = "https://cat-fact.herokuapp.com/facts"
    var dataArray = [CellObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "customFactCell")
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 120.0;
        
        getFactsData(url: CATS_URL)
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "userlogin")
        performSegue(withIdentifier: "logOutSegue", sender: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFactCell", for: indexPath) as! CustomCell

        cell.userNameLabel.text! = dataArray[indexPath.row].userName
        cell.catFactLabel.text! = dataArray[indexPath.row].catFact

        return cell
    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Get data from API
    
    func getFactsData(url: String) {
        SVProgressHUD.show()
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if let facts = json["all"].array {
                    for fact in facts {
                        //fact["text"]
                        //fact["user"]["name"]["first"]
                        //fact["user"]["name"]["last"]
                        let text = fact["text"].string!
                        let userName = "\(fact["user"]["name"]["first"])  \(fact["user"]["name"]["last"])"
                        
                        self.dataArray.append(CellObject(userName, text))
                    }
                    
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
                SCLAlertView().showError("Ooops...", subTitle: "Some problems with connection, please try again later", closeButtonTitle: "Ok")
            }
            
            SVProgressHUD.dismiss()
        }
    }

}

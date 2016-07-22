//
//  ViewController.swift
//  testAutolayout
//
//  Created by Ha Lam on 7/19/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableViewBookList: UITableView!
    
    var numberRowLH:Int = 0
    var arrList:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableViewBookList.delegate = self;
//        tableViewBookList.dataSource = self;
        
        let myBundle = Bundle.main
        let myNib = UINib(nibName: "BookTableViewCell", bundle: myBundle)
        tableViewBookList.register(myNib, forCellReuseIdentifier: "bookcell")
        
        parseJsonFromUrl()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    func parseJsonFromUrl(){
        let urlLH = URL(string:"http://192.168.1.142:8080/data.json")!
        URLSession.shared.dataTask(with: urlLH) { (data, response, err) in
            do {
                guard let jsonLH = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String,AnyObject> else {print ("[Die] Parse Json die"); return}
                
                guard let totalLH = jsonLH["total"],
                    let dataLH = jsonLH["data"] else {print("die");return}
                
                self.numberRowLH = totalLH as! Int
                let data2 = dataLH as! Array<Dictionary<String,String>>
                for (index, value) in data2.enumerated(){
                    self.arrList.insert(value["booktitle"]!, at: index)
                }
                self.tableViewBookList.dataSource = self;//tranh chua co data da load
                DispatchQueue.main.async(execute: {
                    self.tableViewBookList.reloadData()
                })
            } catch {
                print("Error with Json: \(error)")
            }
            }.resume()
    }
}


extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRowLH;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewBookList.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath) as! BookTableViewCell
        cell.titileBook.text = arrList[indexPath.row]
        return cell;
        
    }
}



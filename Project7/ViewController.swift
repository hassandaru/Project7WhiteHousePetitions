//
//  ViewController.swift
//  Project7
//
//  Created by Hassan Sohail Dar on 22/8/2022.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    
    //     let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
    var urlString: String = ""
    
    var searchString = ""
    var searchPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(searchAndUpdateResults))
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                // we're OK to parse!
                parse(json: data)
                return
            }
        }
        showError()
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            searchPetitions = petitions
            tableView.reloadData()
        }
    }
    
    @objc func showCredits () {
        let creditText = "The data comes from \(urlString)"
        let ac = UIAlertController(title: "Credits", message: creditText, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func searchAndUpdateResults() {
        //empty them out.
        searchString = ""
        searchPetitions = []
        
        let getSearchString = UIAlertController(title: "Search String", message: nil, preferredStyle: .alert)
        getSearchString.addTextField()
        
        let submitAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak getSearchString] _ in
            guard let myString = getSearchString?.textFields?[0].text?.lowercased() else { return }
            self?.searchString = myString
            
            self?. performSelector(inBackground: #selector(self?.searchAction), with: nil)
            
            
        }
        getSearchString.addAction(#selector(submitAction))
        present(getSearchString, animated: true)
    }
    
    @objc func searchAction() {
        
        if searchString == "" {
            searchPetitions = petitions
        }
        else {
            searchPetitions = petitions.filter
            {  $0.title.lowercased().contains(searchString) }
        }
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Items = \(searchPetitions.count)")
        return searchPetitions.count
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = searchPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = searchPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


//
//  LocationSearchVC.swift
//  WeatherApp
//
//  Created by Minju on 27/05/2020.
//  Copyright © 2020 KimMinJu. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchVC: UIViewController {
    
    let searchCompleter = MKLocalSearchCompleter()
    var searchController = UISearchController()
    var locationList = [MKLocalSearchCompletion]()
    var completion: ((LocationModel) -> Void)?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initSearchBar()
    }
    
    func initSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = true
        
        searchCompleter.delegate = self
        searchCompleter.filterType = .locationsOnly

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
}

// MARK: - Search Bar
extension LocationSearchVC: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchCompleter.queryFragment = searchController.searchBar.text ?? ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Mapkit Local Search
extension LocationSearchVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.locationList = completer.results
        self.tableView.reloadData()
    }
}

// MARK: - TableView
extension LocationSearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchCell", for: indexPath) as? LocationSearchCell else {
            fatalError("This cell is not an instance of LocationSearchCell")
        }
        
        let item = self.locationList[indexPath.row]
        
        cell.titleLbl.text    = item.title
        cell.subTitleLbl.text = item.subtitle.isEmpty ? "-" : item.subtitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchController.dismiss(animated: true, completion: nil)
        
        let item = self.locationList[indexPath.row]

        let searchRequest = MKLocalSearch.Request(completion: item)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard error == nil else {
                return
            }
            guard let placeMark = response?.mapItems[0].placemark else {
                return
            }
            let latitude = placeMark.coordinate.latitude
            let longtitude = placeMark.coordinate.longitude
            let location = LocationModel(address: item.title,
                                         latitude: latitude,
                                         longtitude: longtitude,
                                         dataKind: DataKind.search.rawValue)

            self.completion?(location)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

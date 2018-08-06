//
//  QuotesListViewController.swift
//  resultant
//
//  Created by Gennady Dmitrik on 06.08.2018.
//  Copyright © 2018 Gennady Dmitrik. All rights reserved.
//

import UIKit

class QuotesListViewController: UIViewController {
    @IBOutlet weak var topPanelView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var quotesListTableView: UITableView!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var msgLabel: UILabel!
    
    let quotesListTableViewCellIdentifier = "QuotesListTableViewCellIdentifier"
    let quotesListTableViewHeaderIdentifier = "QuotesListTableViewHeaderIdentifier"
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh...")
        refreshControl.addTarget(self, action: #selector(refreshButtonPressed), for: .valueChanged)
        quotesListTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(startRefreshQuotesData), name: Fields.didStartRefreshNotification, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(endRefreshQuotesData), name: Fields.didEndRefreshNotification, object:nil)
        quotesListTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Fields.didStartRefreshNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Fields.didEndRefreshNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        APIManager.shared.refreshQuotesData()
    }
    
    @objc func startRefreshQuotesData() {
        DispatchQueue.main.async {
            self.refreshButton.isHidden = true
            self.activitySpinner.startAnimating()
            self.activitySpinner.isHidden = false
        }
    }
    
    @objc func endRefreshQuotesData(notification: Notification) {
        guard let userInfo = notification.userInfo, let state = userInfo["state"] as? String else {
            print("No userInfo found in notification")
            return
        }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.activitySpinner.stopAnimating()
            self.activitySpinner.isHidden = true
            self.refreshButton.isHidden = false
            if state == "error" {
                self.msgLabel.text = "Check Internet conn"
            } else if DataSource.shared.quotesData.isEmpty {
                self.msgLabel.text = "Got empty result"
            } else {
                self.msgLabel.text = ""
            }
            self.quotesListTableView.reloadData()
        }
    }
}

//mark: - UITableViewDelegate
extension QuotesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: quotesListTableViewHeaderIdentifier)
    }
}

//mark: - UITableViewDataSource
extension QuotesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: quotesListTableViewCellIdentifier) as! QuotesListTableViewCell
        cell.nameLabel.text = DataSource.shared.quotesData[indexPath.row][Fields.name] as? String ?? ""
        cell.volumeLabel.text = DataSource.shared.quotesData[indexPath.row][Fields.volume]?.stringValue
        if let price = DataSource.shared.quotesData[indexPath.row][Fields.price], let amount = price[Fields.amount] as? Double {
            cell.amountLabel.text = "\(String(format: "%.2f", amount))"
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.quotesData.count
    }
}

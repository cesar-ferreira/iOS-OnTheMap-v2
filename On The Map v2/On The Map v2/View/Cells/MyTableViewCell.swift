//
//  MyTableViewCell.swift
//  onTheMap
//
//  Created by César Ferreira on 17/04/21.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MyTableViewCell"

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static func nib() -> UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}


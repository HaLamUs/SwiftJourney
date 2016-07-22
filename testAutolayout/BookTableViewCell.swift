//
//  BookTableViewCell.swift
//  testAutolayout
//
//  Created by Ha Lam on 7/19/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarBook: UIImageView!
    @IBOutlet weak var titileBook: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarBook.layer.cornerRadius = self.bounds.height / 2
        avatarBook.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//
//  PlaylistTableViewCell.swift
//  music
//
//  Created by Atakishiyev Orazdurdy on 5/19/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet var albumArtworkImageView: UIImageView?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var artistAndAlbumNameLabel: UILabel?
    
    override var layoutMargins: UIEdgeInsets { get { return UIEdgeInsetsZero } set(newVal) {} }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
//
//  SearchPhotoCell.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/19/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import UIKit

class SearchPhotoCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    
    func setCell(data: SearchPhotoEntity) {
        title.text = data.title
        
        if let thumbnailUrl = data.thumbnailUrl, let url = URL(string: thumbnailUrl) {
            coverImage.kf.setImage(with: url) { [weak self] (_, error, _, _) in
                if let strongSelf = self, error == nil {
                    strongSelf.coverImage.clipsToBounds = true
                    strongSelf.coverImage.contentMode = .scaleAspectFill
                }
            }
        } else {
            coverImage.image = nil
            coverImage.clipsToBounds = false
            coverImage.contentMode = .scaleToFill
        }
    }
}

//
//  ImageLoader.swift
//  DescontaAi
//
//  Created by Yuri Elias on 17/11/26.
//

import UIKit

final class ImageLoader {
    static func loadImage(
        from urlString: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data, error == nil else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}

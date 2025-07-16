//
//  POIImageView.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/2/25.
//

import SwiftUI

public struct POIImageView: View {
    let imagePath: String?

    public init(imagePath: String?) {
        self.imagePath = imagePath
    }

    public var body: some View {
        VStack {
            if let imagePath,
               let imageName = imagePath.split(separator: "/").last {
                let components = imageName.split(separator: ".")
                if components.count == 2 {
                    let name = String(components[0])
                    let ext = String(components[1])
                    if let url = Bundle.main.url(forResource: name, withExtension: ext),
                       let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("❌ \(name).\(ext)")
                            .foregroundColor(.red)
                        Text("Path: \(imagePath)")
                            .font(.caption)
                    }
                } else {
                    Text("❌ Invalid path: \(imagePath)")
                }
            } else {
                Text("No image")
            }
        }
    }
}

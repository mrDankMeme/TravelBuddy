//
//  UITabBarController+Alert.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 9/28/25.
//


import UIKit

extension UITabBarController {
    func presentAlert(title: String, message: String, okTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default))
        (selectedViewController ?? presentedViewController ?? self).present(alert, animated: true)
    }
}

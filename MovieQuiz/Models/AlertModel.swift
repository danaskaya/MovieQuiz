//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 14.09.2024.
//

import Foundation
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}

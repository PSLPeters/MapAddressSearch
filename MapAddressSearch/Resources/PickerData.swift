//
//  PickerData.swift
//  MapAddressSearch
//
//  Created by Michael Peters on 3/16/24.
//

import Foundation

struct mapStyles : Identifiable {
    let id = UUID()
    let name : String
}

let arrMapStyles =
    [
        mapStyles(name: "Standard"),
        mapStyles(name: "Hybrid"),
        mapStyles(name: "Imagery")
    ]

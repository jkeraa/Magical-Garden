//
//  DropDownMenu.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import SwiftUI

let onBoardingData : [OnBoardingItem] = [
    OnBoardingItem(
        title: {
        var title = AttributedString("Welcome to your \n   Magical \n           Garden")
        if let range = title.range(of: "Magical") {
            title[range].foregroundColor = metallicBlue
        }
            if let range = title.range(of: "Garden") {
                title[range].foregroundColor = metallicBlue
            }
        return title
    }(), image: Image(systemName: "leaf.fill"),
        description: {
        var description = AttributedString("Begin your enchanting journey in AR !")
        if let range = description.range(of: "AR") {
            description[range].foregroundColor = metallicBlue
        }
         

        return description
            
    }()),
    OnBoardingItem( title: {
        var title = AttributedString( "Place                     \nYour Mystical Plants")
        if let range = title.range(of: "Plants") {
            title[range].foregroundColor = metallicBlue
        }
        return title
        }(), image: Image(systemName: "hand.tap.fill"),
            description: {
            var description = AttributedString("Find the perfect spot")
            if let range = description.range(of: "spot") {
                description[range].foregroundColor = metallicBlue
            }
            return description
        }()),
    OnBoardingItem(title: {
        var title = AttributedString( "Nurture Your \nPlants                   .")
        if let range = title.range(of: "Nurture") {
            title[range].foregroundColor = metallicBlue
        }
        if let range = title.range(of: ".") {
            title[range].foregroundColor = Color(.clear)
        }
        return title
        }(), image: Image(systemName: "drop.degreesign.fill"),
                  description: {
                  var description = AttributedString("Respond to their calls")
                  if let range = description.range(of: "calls") {
                      description[range].foregroundColor = metallicBlue
                  }
                  return description
              }()),
    OnBoardingItem(title: {
        var title = AttributedString( "Unlock \nthe Garden Bloom.          ,")
        if let range = title.range(of: "Bloom") {
            title[range].foregroundColor = metallicBlue
        }
        if let range = title.range(of: ".") {
            title[range].foregroundColor = Color(.clear)
        }
        if let range = title.range(of: ",") {
            title[range].foregroundColor = Color(.clear)
        }
        return title
        }(), image: Image(systemName: "light.max"),
                  description: {
                  var description = AttributedString("Witness the magic unfold")
                  if let range = description.range(of: "magic") {
                      description[range].foregroundColor = metallicBlue
                  }
                      if let range = description.range(of: "music experience") {
                          description[range].foregroundColor = metallicBlue
                      }
                  return description
              }())
]

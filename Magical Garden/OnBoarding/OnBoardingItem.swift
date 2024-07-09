//
//  OnBoardingItem.swift
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 05/07/24.
//

import Foundation
import SwiftUI

struct OnBoardingItem: Identifiable {
  var id = UUID()
  var title: AttributedString
  var image: Image
  var description: AttributedString
}

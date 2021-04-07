//
//  Themes.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-03-30.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import Foundation
import UIKit

class Themes {
    
    enum Theme: String {
        case Green
        case Teal
    }
    
    static func storeTheme(theme: Theme) {
        
        // First store the selected theme in.
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        UserDefaults.standard.synchronize()
    }
    
    enum AssetsColor : String {
      case background
    }
    
}

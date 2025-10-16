//
//  AppDelegate.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 8/31/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import SwiftUI

@main
struct SquirrelDesigner: App {
    let viewModel = ViewModel.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(viewModel)
        }
        .defaultSize(width: 1152, height: 486)
    }
}

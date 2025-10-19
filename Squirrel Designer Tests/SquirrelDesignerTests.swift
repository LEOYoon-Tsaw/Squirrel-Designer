//
//  Squirrel_Designer_Tests.swift
//  Squirrel Designer Tests
//
//  Created by Leo Liu on 10/19/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import Testing
import Yams
import Foundation

struct Squirrel_Designer_Tests {

    @Test("Decode and encode initial Squirrel settings")
    func squirrelSettings() async throws {
        let squirrelSettingsFile = URL(fileURLWithPath: Bundle.main.path(forResource: "squirrel_settings", ofType: "yaml")!)
        let settingsData = try Data(contentsOf: squirrelSettingsFile)
        let decoder = YAMLDecoder()
        let settings = try decoder.decode(SquirrelSetting.self, from: settingsData)
        #expect(type(of: settings) == SquirrelSetting.self)
    }
    
    @Test("Decode and encode initial input templates")
    func inputTemplates() async throws {
        let inputTemplatesFile = URL(fileURLWithPath: Bundle.main.path(forResource: "input_template", ofType: "yaml")!)
        let inputData = try Data(contentsOf: inputTemplatesFile)
        let decoder = YAMLDecoder()
        let input = try decoder.decode(InputTemplate.self, from: inputData)
        #expect(type(of: input) == InputTemplate.self)
    }
}

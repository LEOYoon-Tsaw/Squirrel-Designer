//
//  DataModel.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/24/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI
import SwiftData
import Foundation
import Yams

typealias DataSchema = DataSchemaV1
extension DataSchema {
    static let container = {
        let fullSchema = Schema(versionedSchema: DataSchema.self)
#if DEBUG
        let modelConfig = ModelConfiguration("MainData-debug", schema: fullSchema, groupContainer: .automatic, cloudKitDatabase: .none)
#else
        let modelConfig = ModelConfiguration("MainData", schema: fullSchema, groupContainer: .automatic, cloudKitDatabase: .none)
#endif
        return createContainer(schema: fullSchema, migrationPlan: DataMigrationPlan.self, configurations: [modelConfig])
    }()
}

typealias ConfigData = DataSchema.ConfigData
extension ConfigData {
    static func load(context: ModelContext) throws -> Self {
        let descriptor = FetchDescriptor<Self>()
        if let data = try context.fetch(descriptor).first {
            return data
        } else {
            let settingsFile = URL(fileURLWithPath: Bundle.main.path(forResource: "squirrel_settings", ofType: "yaml")!)
            let inputFile = URL(fileURLWithPath: Bundle.main.path(forResource: "input_template", ofType: "yaml")!)
            let squirrelSettings = try Data(contentsOf: settingsFile)
            let inputTemplate = try Data(contentsOf: inputFile)
            let newData = Self(setting: squirrelSettings, input: inputTemplate)
            context.insert(newData)
            return newData
        }
    }

    var squirrelSetting: SquirrelSetting {
        get {
            let decoder = YAMLDecoder()
            do {
                return try decoder.decode(SquirrelSetting.self, from: squirrelSettingData)
            } catch {
                print("Unable to decode Squirrel setting data\nData: \(String(data: squirrelSettingData, encoding: .utf8) ?? "(empty)")\nError: \(error)\n")
                return SquirrelSetting()
            }
        } set {
            do {
                let encoder = YAMLEncoder()
                squirrelSettingData = try encoder.encode(newValue).data(using: .utf8)!
            } catch {
                print("Unable to encode Squirrel setting from update \(error)")
            }
        }
    }

    var inputTemplate: InputTemplate {
        get {
            let decoder = YAMLDecoder()
            do {
                return try decoder.decode(InputTemplate.self, from: squirrelInputData)
            } catch {
                print("Unable to decode Squirrel input template data\nData:\n\(String(data: squirrelInputData, encoding: .utf8) ?? "(empty)")\nError: \(error)\n")
                return InputTemplate()
            }
        } set {
            do {
                let encoder = YAMLEncoder()
                squirrelInputData = try encoder.encode(newValue).data(using: .utf8)!
            } catch {
                print("Unable to encode Squirrel input template from update \(error)")
            }
        }
    }
}

enum DataSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        .init(1, 0, 0)
    }
    static var models: [any PersistentModel.Type] {
        [ConfigData.self]
    }

    @Model final class ConfigData {
        @Attribute(.allowsCloudEncryption, .unique) var squirrelSettingData: Data
        @Attribute(.allowsCloudEncryption, .unique) var squirrelInputData: Data

        init(setting: Data, input: Data) {
            squirrelSettingData = setting
            squirrelInputData = input
        }
    }
}

enum DataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DataSchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}

private func createContainer(schema: Schema, migrationPlan: SchemaMigrationPlan.Type? = nil, configurations: [ModelConfiguration]) -> ModelContainer {
    do {
        return try ModelContainer(for: schema, migrationPlan: migrationPlan, configurations: configurations)
    } catch {
        print(error.localizedDescription)
        do {
            return try ModelContainer(for: schema, configurations: configurations)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

enum Selection: Hashable {
    case style
    case template
    case colorScheme(Int)
    case allSettings
}

enum DesignerError: Error {
    case yamlError(YamlError)
    case decoding(DecodingError)
    case encoding(EncodingError)
    case renaming(RenamingError)
    case other(any Error)
}

@Observable final class ViewModel: Bindable {
    static let shared = ViewModel()

    @ObservationIgnored private(set) lazy var panel = SquirrelPanel(position: .zero)
    @ObservationIgnored let gridColumns: [GridItem] = [.init(.flexible(minimum: 200, maximum: 600), spacing: 30), .init(.flexible(minimum: 200, maximum: 600))]
    @ObservationIgnored private let configData: ConfigData
    @ObservationIgnored let container: ModelContainer
    @ObservationIgnored let undoManager: UndoManager
    var squirrelSetting: SquirrelSetting
    var inputTemplate: InputTemplate
    var selection: Selection = .style
    var showingCode: Bool = false
    var previewing: Bool = false
    @ObservationIgnored var previewPosition: CGPoint?
    @ObservationIgnored var saveTask: Task<Void, Never>?
    @ObservationIgnored private var undoObservers: [NSObjectProtocol] = []
    var error: DesignerError?
    var hasError: Bool {
        get {
            error != nil
        } set {
            if !newValue {
                error = nil
            }
        }
    }

    private func startObservingUndoRedo() {
        let center = NotificationCenter.default

        let didUndo = center.addObserver(
            forName: .NSUndoManagerDidUndoChange,
            object: undoManager,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.squirrelSetting = self.configData.squirrelSetting
                self.inputTemplate = self.configData.inputTemplate
            }
        }

        let didRedo = center.addObserver(
            forName: .NSUndoManagerDidRedoChange,
            object: undoManager,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.squirrelSetting = self.configData.squirrelSetting
                self.inputTemplate = self.configData.inputTemplate
            }
        }

        undoObservers = [didUndo, didRedo]
    }

    private func stopObservingUndoRedo() {
        let center = NotificationCenter.default
        undoObservers.forEach { center.removeObserver($0) }
        undoObservers.removeAll()
    }

    private init() {
        container = DataSchema.container
        undoManager = UndoManager()
        container.mainContext.undoManager = undoManager
        do {
            configData = try ConfigData.load(context: container.mainContext)
        } catch {
            fatalError(error.localizedDescription)
        }
        squirrelSetting = configData.squirrelSetting
        inputTemplate = configData.inputTemplate
        startObservingUndoRedo()
    }

    fileprivate init(context: ModelContext) {
        container = context.container
        undoManager = context.undoManager ?? UndoManager()
        do {
            configData = try ConfigData.load(context: context)
        } catch {
            fatalError(error.localizedDescription)
        }
        squirrelSetting = configData.squirrelSetting
        inputTemplate = configData.inputTemplate
        startObservingUndoRedo()
    }

    func save() {
        if self.configData.inputTemplate != self.inputTemplate || self.configData.squirrelSetting != self.squirrelSetting {
            undoManager.beginUndoGrouping()
            self.configData.squirrelSetting = self.squirrelSetting
            self.configData.inputTemplate = self.inputTemplate
            if container.mainContext.hasChanges {
                try? container.mainContext.save()
            }
            undoManager.endUndoGrouping()
        }
    }
}

struct SampleData: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let fullSchema = Schema(versionedSchema: DataSchema.self)
        let modelConfig = ModelConfiguration("MainData-Preview", schema: fullSchema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: fullSchema, configurations: [modelConfig])
        let encoder = YAMLEncoder()
        let configData = try ConfigData(setting: encoder.encode(SquirrelSetting()).data(using: .utf8)!, input: encoder.encode(InputTemplate()).data(using: .utf8)!)
        container.mainContext.undoManager = UndoManager()
        container.mainContext.insert(configData)
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        let viewModel = ViewModel(context: context.mainContext)
        content
            .environment(viewModel)
    }
 }

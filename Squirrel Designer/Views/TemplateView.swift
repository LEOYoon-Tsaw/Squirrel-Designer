//
//  Template.swift
//  Squirrel Designer
//
//  Created by Leo Liu on 9/26/25.
//  Copyright © 2025 Yuncao Liu. All rights reserved.
//

import SwiftUI

struct TemplateView: View {
    @Environment(ViewModel.self) var viewModel
    private var _template: Binding<InputTemplate> {
        Binding(get: {
            viewModel.inputTemplate
        }, set: { newValue in
            viewModel.inputTemplate = newValue
            viewModel.saveTask?.cancel()
            viewModel.saveTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                viewModel.save()
            }
        })
    }
    private var template: InputTemplate {
        _template.wrappedValue
    }

    var body: some View {
        Form {
            preeditSection
            candidatesSection
        }
        .formStyle(.grouped)
        .navigationTitle("TEMPLATE")
    }

    var preeditSection: some View {
        Section("PREEDIT") {
            TextField("PREEDIT_BEFORE_HILIT", text: _template.preedit.beforeHighlighted)
            TextField("PREEDIT_HILIT", text: _template.preedit.highlighted)
            TextField("PREEDIT_AFTER_HILIT", text: _template.preedit.afterHighlighted)
        }
        .textFieldStyle(.roundedBorder)
    }

    var candidatesSection: some View {
        Section {
            ForEach(0..<_template.candidates.count, id: \.self) { index in
                let selected = Binding(get: { template.selection == index }, set: { on in
                    if on {
                        _template.selection.wrappedValue = index
                    }
                })
                CandidateRow(candidate: _template.candidates[index], selected: selected) {
                    if index < _template.candidates.count {
                        _template.wrappedValue.candidates.remove(at: index)
                        if template.selection >= template.candidates.count {
                            _template.selection.wrappedValue = max(0, template.candidates.count - 1)
                        }
                    }
                }
            }
        } header: {
            AddableTitle(title: "CANDIDATES", show: true) {
                Button {
                    var newCandidate = Candidate()
                    newCandidate.label = "\(template.candidates.count + 1)"
                    _template.wrappedValue.candidates.append(newCandidate)
                } label: {
                    Label("ADD_ITEM", systemImage: "plus.circle")
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
            }
        }
    }
}

struct CandidateRow: View {
    let onDelete: @MainActor () -> Void
    let candidate: Binding<Candidate>
    let selected: Binding<Bool>

    init(candidate: Binding<Candidate>, selected: Binding<Bool>, onDelete: sending @escaping @MainActor () -> Void) {
        self.onDelete = onDelete
        self.candidate = candidate
        self.selected = selected
    }

    var body: some View {
        HStack {
            Toggle("SELECTED", isOn: selected)
                .labelsHidden()
            TextField("LABEL", text: candidate.label)
            TextField("CAND", text: candidate.text)
            TextField("COMMENT", text: candidate.comment)
            deleteButton
        }
        .textFieldStyle(.roundedBorder)
    }

    var deleteButton: some View {
        Button {
            onDelete()
        } label: {
            Label("DELETE_ROW", systemImage: "minus.circle")
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }
}

#Preview("TemplateView", traits: .modifier(SampleData())) {
    TemplateView()
}

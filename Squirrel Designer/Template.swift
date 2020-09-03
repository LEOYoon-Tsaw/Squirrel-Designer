//
//  Template.swift
//  Squirrel Designer
//
//  Created by LEO Yoon-Tsaw on 9/1/20.
//  Copyright © 2020 Yuncao Liu. All rights reserved.
//

import Foundation

class InputSource: NSObject {
    var preedit = "漢皇重色思傾國竹人人止中 十一木 弓戈弓戈 人手 戈十水 一火 竹人日一戈 木日一竹 十一尸人 大月 女 中尸竹 尸一女 戈竹尸 廿人戈日女 大中土 水月金木 日弓土土‸ojdyryia"
    var selRange = NSMakeRange(7, 77)
    var candidates: Array<String> = ["御宇多年求不得楊家有女初長成養在深閨", "御宇多年求不得", "御宇多年", "御宇", "御", "八"]
    var comments: Array<String> = ["", "", "", "", "疑依模去、疑娃歌去", "幫娃先入"]
    var labels: Array<String> = ["〡", "〢", "〣", "〤", "〥", "〦", "〧", "〨", "〩"]
    var index: UInt = 0
    var candidateFormat = "%c. %@"
    
    func encode() -> String {
        var encoded = ""
        encoded += "preedit:\(preedit)\n"
        encoded += "sel_range:\(selRange.lowerBound)-\(selRange.upperBound)\n"
        encoded += "candidates:\(candidates.joined(separator: ","))\n"
        encoded += "comments:\(comments.joined(separator: ","))\n"
        encoded += "labels:\(labels.joined(separator: ","))\n"
        encoded += "index:\(index)\n"
        encoded += "candidate_format:\(candidateFormat)"
        return encoded
    }
    
    func decode(from string: String) {
        let regex = try! NSRegularExpression(pattern: "([a-z_0-9]+):(.+)$", options: .caseInsensitive)
        var values = Dictionary<String, String>()
        for line in string.split(whereSeparator: \.isNewline) {
            let line = String(line)
            let matches = regex.matches(in: line, options: .init(rawValue: 0), range: NSMakeRange(0, line.endIndex.utf16Offset(in: line)))
            for match in matches {
                values[(line as NSString).substring(with: match.range(at: 1))] = (line as NSString).substring(with: match.range(at: 2))
            }
        }
        let preedit = values["preedit"]
        var selRange: NSRange?
        if let rangeString = values["sel_range"]?.split(separator: "-"),
            let lowerString = rangeString.first,
            let upperString = rangeString.last,
            let lower = Int(lowerString),
            let upper = Int(upperString)
        {
            selRange = NSMakeRange(lower, upper-lower)
        }
        var candidates = Array<String>()
        if let candidatesString = values["candidates"] {
            for candidateString in candidatesString.split(separator: ",") {
                candidates.append(String(candidateString))
            }
        }
        var comments = Array<String>()
        if let commentsString = values["comments"] {
            for commentString in commentsString.split(separator: ",") {
                comments.append(String(commentString))
            }
        }
        var labels = Array<String>()
        if let labelsString = values["labels"] {
            for labelString in labelsString.split(separator: ",") {
                labels.append(String(labelString))
            }
        }
        var index: UInt?
        if let indexString = values["index"],
            let _index = UInt(indexString) {
            index = _index
        }
        let candidateFormat = values["candidate_format"]
        
        self.preedit = preedit == nil ? self.preedit : preedit!
        self.selRange = selRange == nil ? self.selRange : selRange!
        self.candidates = candidates.isEmpty ? self.candidates : candidates
        self.comments = comments.isEmpty ? self.comments : comments
        self.labels = labels.isEmpty ? self.labels : labels
        self.index = index == nil ? self.index : index!
        self.candidateFormat = candidateFormat == nil ? self.candidateFormat : candidateFormat!
    }
}

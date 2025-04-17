// ProjectName: DrinkPartyRoulette
// Script Name: Member.swift
//  Created by 橋本諭 on 2025/04/14.

// MARK: - Import
import Foundation

// MARK: - JSONデータ読込用の構造体
/// - Identifiable：SwiftUIでListなどに表示するために必要（.idを使う）
/// - Codable：JSON読み書き可能にするために必要
/// - Hashable：SetやDictionaryで重複を防ぐために使えるように
struct Member: Identifiable, Codable, Hashable {
    var id: Int                   // ← ここを id: UUID = UUID() から Int に修正
    var name: String
    var department: String
}

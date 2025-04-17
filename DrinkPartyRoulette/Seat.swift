// ProjectName: DrinkPartyRoulette
// Script Name: Seat.swift
//  Created by 橋本諭 on 2025/04/14.
//
//  Created by 橋本諭 on 2025/04/14.
//


import Foundation

// MARK: - アプリの座席管理用のデータモデル
struct Seat: Identifiable {
    let id: Int         // 座席番号 (1〜40)
    var member: Member? // 誰が座っているか（空席なら nil）
}


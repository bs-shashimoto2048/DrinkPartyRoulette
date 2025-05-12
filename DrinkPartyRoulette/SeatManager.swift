// ProjectName: DrinkPartyRoulette
// Script Name: SeatManager.swift
//  Created by 橋本諭 on 2025/04/15.

// MARK: 座席の空き状況や、JSONからの名簿読み込みなどを扱う 状態管理クラス(ViewModel)
// - @Published: SwiftUIに変更通知を伝えるプロパティ
// - loadMembers(): JSONファイルからメンバーを読み込み
// - setupSeats(): 30席を用意して初期化
// - assignRandomSeat(to:): 空いてる席から1つを選び、指定した人を割り当てる
// - departments: 部署一覧を取得
// - membersInSelectedDepartment: 選んだ部署の未割当メンバーの一覧


import Foundation
import SwiftUI
class SeatManager: ObservableObject {
    @Published var seats: [Seat] = []
    @Published var members: [Member] = []
    @Published var selectedDepartment: String = ""
    @Published var selectedMember: Member?

    // VIPとVIP席の設定（VIPのID, VIP専用座席ID）
    private let vipIDs: [Int] = [1, 2, 32] // ←VIP の id 番号を設定
    private let vipSeatIDs: [Int] = [1, 7, 13] // テーブル1〜3にVIP席を1つずつ設定

    init() {
        loadMembers()
        setupSeats()
    }

    func setupSeats() {
        // 6席×5テーブル = 30席
        seats = (1...30).map { Seat(id: $0, member: nil) }
    }

    func loadMembers() {
        if let url = Bundle.main.url(forResource: "members", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([Member].self, from: data)
                members = decoded
            } catch {
                print("JSON読み込み失敗: \(error)")
            }
        }
    }

    var departments: [String] {
        Array(Set(members.map { $0.department })).sorted()
    }

    var membersInSelectedDepartment: [Member] {
        members.filter { member in
            member.department == selectedDepartment &&
            !assignedMembers.contains(where: {
                $0.name == member.name && $0.department == member.department
            })
        }
    }

    var assignedMembers: [Member] {
        seats.compactMap { $0.member }
    }

    func assignRandomSeat(to member: Member) {
        // VIPメンバーかどうかを判定
        let isVIP = vipIDs.contains(member.id)

        if isVIP {
            // 空いてるVIP席を取得
            let availableVIPSeats = seats.filter { vipSeatIDs.contains($0.id) && $0.member == nil }

            // 空いてるVIP席があればランダムで割り当て
            if let vipSeat = availableVIPSeats.randomElement(),
               let index = seats.firstIndex(where: { $0.id == vipSeat.id }) {
                seats[index].member = member
                return
            }
        }

        // 通常の空席からランダムで割り当て
        let availableSeats = seats.filter { $0.member == nil && !vipSeatIDs.contains($0.id) }

        if let randomSeat = availableSeats.randomElement(),
           let index = seats.firstIndex(where: { $0.id == randomSeat.id }) {
            seats[index].member = member
        }
    }
}

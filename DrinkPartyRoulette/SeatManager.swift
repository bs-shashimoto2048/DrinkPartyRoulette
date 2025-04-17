// ProjectName: DrinkPartyRoulette
// Script Name: SeatManager.swift
//  Created by 橋本諭 on 2025/04/15.

// MARK: 座席の空き状況や、JSONからの名簿読み込みなどを扱う 状態管理クラス(ViewModel)
// - @Published: SwiftUIに変更通知を伝えるプロパティ
// - loadMembers(): JSONファイルからメンバーを読み込み
// - setupSeats(): 40席を用意して初期化
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

    init() {
        loadMembers()
        setupSeats()
    }

    func setupSeats() {
        // 5列 x 8行の座席を作成（最初は空席）
        seats = (1...40).map { Seat(id: $0, member: nil) }
    }

    func loadMembers() {
        // バンドルから JSON 読み込み
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
        // 登録されている部署名をユニークに抽出
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
        // 空いてる席をランダムに1つ選んで割り当てる
        let availableSeats = seats.filter { $0.member == nil }
        guard let randomSeat = availableSeats.randomElement() else { return }

        if let index = seats.firstIndex(where: { $0.id == randomSeat.id }) {
            seats[index].member = member
        }
    }
}


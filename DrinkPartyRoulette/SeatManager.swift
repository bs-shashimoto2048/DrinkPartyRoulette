// ProjectName: DrinkPartyRoulette
// Script Name: SeatManager.swift
//  Created by 橋本諭 on 2025/07/25.

// MARK: 座席の空き状況や、JSONからの名簿読み込みなどを扱う 状態管理クラス(ViewModel)
// - @Published: SwiftUIに変更通知を伝えるプロパティ
// - loadMembers(): JSONファイルからメンバーを読み込み
// - setupSeats(): 30席を用意して初期化
// - assignRandomSeat(to:): 空いてる席から1つを選び、指定した人を割り当てる
// - departments: 部署一覧を取得
// - membersInSelectedDepartment: 選んだ部署の未割当メンバーの一覧
// - VIP席を２列へ修正(１列目：役職者、２列目：歓迎者)


import Foundation
import SwiftUI


/// VIP 2列バージョン
class SeatManager: ObservableObject {
    @Published var seats: [Seat] = []
    @Published var members: [Member] = []
    @Published var selectedDepartment: String = ""
    @Published var selectedMember: Member?

    // 役職者用 VIP メンバーID
    let vipIDs: [Int] = [1, 2, 3, 12, 13, 18, 19, 32]
    // 役職者用 VIP 席ID
    let vipSeatIDs: [Int] = [1, 5, 9, 13, 17, 21]

    // 歓迎者様用 VIP メンバーID
    let welcomeVIPIDs: [Int] = [10, 16, 17, 22, 25,29] // 必要に応じて変更
    // 歓迎者様用 VIP 席ID（例：特定席を歓迎者様用に確保）
    let welcomeVIPSeatIDs: [Int] = [2, 6, 10, 14, 18, 22]

    init() {
        loadMembers()
        setupSeats()
    }

    func setupSeats() {
        seats = (1...24).map { Seat(id: $0, member: nil) }
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
        let assignedDepartments = Set(members.filter { assignedMembers.contains($0) }.map { $0.department })
        let availableDepartments = members.map { $0.department }.filter { !assignedDepartments.contains($0) }
        return Array(Set(availableDepartments)).sorted()
    }

    var membersInSelectedDepartment: [Member] {
        members.filter { member in
            member.department == selectedDepartment &&
            !assignedMembers.contains(where: { $0.name == member.name && $0.department == member.department })
        }
    }

    var assignedMembers: [Member] {
        seats.compactMap { $0.member }
    }

    func assignRandomSeat(to member: Member) {
        let isVIP = vipIDs.contains(member.id)
        let isWelcomeVIP = welcomeVIPIDs.contains(member.id)

        if isVIP {
            let availableVIPSeats = seats.filter { vipSeatIDs.contains($0.id) && $0.member == nil }
            if let vipSeat = availableVIPSeats.randomElement(),
               let index = seats.firstIndex(where: { $0.id == vipSeat.id }) {
                seats[index].member = member
                removeAssignedMember(member)
                return
            }
        }

        if isWelcomeVIP {
            let availableWelcomeVIPSeats = seats.filter { welcomeVIPSeatIDs.contains($0.id) && $0.member == nil }
            if let welcomeVIPSeat = availableWelcomeVIPSeats.randomElement(),
               let index = seats.firstIndex(where: { $0.id == welcomeVIPSeat.id }) {
                seats[index].member = member
                removeAssignedMember(member)
                return
            }
        }

        // 通常席からランダムに割り当て
        let availableSeats = seats.filter { $0.member == nil && !vipSeatIDs.contains($0.id) && !welcomeVIPSeatIDs.contains($0.id) }

        if let randomSeat = availableSeats.randomElement(),
           let index = seats.firstIndex(where: { $0.id == randomSeat.id }) {
            seats[index].member = member
            removeAssignedMember(member)
        }
    }

    private func removeAssignedMember(_ member: Member) {
        if let index = members.firstIndex(where: { $0.id == member.id }) {
            members.remove(at: index)
        }
    }
}

/// VIP 1列バージョン
//class SeatManager: ObservableObject {
//    @Published var seats: [Seat] = []
//    @Published var members: [Member] = []
//    @Published var selectedDepartment: String = ""
//    @Published var selectedMember: Member?
//
//    // VIPメンバーIDの一覧(社長、専務、室長、MG、SM)
//    let vipIDs: [Int] = [1, 2, 3, 12, 13, 18,19, 32]
//    // VIP席IDの一覧（テーブルごとに1つずつ）
//    let vipSeatIDs: [Int] = [1, 5, 9, 13, 17, 21]
//
//    init() {
//        loadMembers()
//        setupSeats()
//    }
//
//    func setupSeats() {
//        // 4席×6テーブル = 24席
//        seats = (1...24).map { Seat(id: $0, member: nil) }
//    }
//
//    func loadMembers() {
//        if let url = Bundle.main.url(forResource: "members", withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: url)
//                let decoded = try JSONDecoder().decode([Member].self, from: data)
//                members = decoded
//            } catch {
//                print("JSON読み込み失敗: \(error)")
//            }
//        }
//    }
//
//    // 部署の選択肢
//    var departments: [String] {
//        // 部署ごとに割り当てられたメンバーがいない場合のみリストに残す
//        let assignedDepartments = Set(members.filter { assignedMembers.contains($0) }.map { $0.department })
//        let availableDepartments = members.map { $0.department }.filter { !assignedDepartments.contains($0) }
//        return Array(Set(availableDepartments)).sorted()
//    }
//
//    var membersInSelectedDepartment: [Member] {
//        members.filter { member in
//            member.department == selectedDepartment &&
//            !assignedMembers.contains(where: { $0.name == member.name && $0.department == member.department })
//        }
//    }
//
//    var assignedMembers: [Member] {
//        seats.compactMap { $0.member }
//    }
//
//    // ランダムに席を割り当てる
//    func assignRandomSeat(to member: Member) {
//        let isVIP = vipIDs.contains(member.id)
//
//        if isVIP {
//            // 空いているVIP席を取得
//            let availableVIPSeats = seats.filter { vipSeatIDs.contains($0.id) && $0.member == nil }
//
//            if let vipSeat = availableVIPSeats.randomElement(),
//               let index = seats.firstIndex(where: { $0.id == vipSeat.id }) {
//                seats[index].member = member
//                removeAssignedMember(member)
//                return
//            }
//        }
//
//        // 通常席からランダムに割り当て
//        let availableSeats = seats.filter { $0.member == nil && !vipSeatIDs.contains($0.id) }
//
//        if let randomSeat = availableSeats.randomElement(),
//           let index = seats.firstIndex(where: { $0.id == randomSeat.id }) {
//            seats[index].member = member
//            removeAssignedMember(member)
//        }
//    }
//
//    // 割り当て済みメンバーをリストから削除
//    private func removeAssignedMember(_ member: Member) {
//        if let index = members.firstIndex(where: { $0.id == member.id }) {
//            members.remove(at: index)
//        }
//    }
//}

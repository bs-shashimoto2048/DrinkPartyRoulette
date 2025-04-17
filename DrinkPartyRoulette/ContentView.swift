// ProjectName: DrinkPartyRoulette
// Script Name: ContentView.swift
//  Created by 橋本諭 on 2025/04/16.
///　アニメーションのJSOnファイルは  https://lottiefiles.com/ にて入手

// MARK: - 部署選択〜くじ引き、座席(グリッド)画面
/// - LazyVGrid を使って 座席表を作成
/// - ボタンを押すたびに、選ばれた人がランダムな空席に入ります
/// - 割り当てられた席は 緑色、空席は 白 に表示

import SwiftUI
import Lottie // Package のインストールが必要

struct ContentView: View {
    @StateObject private var manager = SeatManager()

    @State private var showLottie = false
    @State private var resultText: String = ""
    // 前回くじ引きされたメンバーを追跡
    @State private var lastAssignedMemberID: Int? = nil

    // MARK: - ピッカー用のカスタマイズパラメータ
    let pickerWidth: CGFloat = 80                 // ピッカーの幅
    let pickerHeight: CGFloat = 20                 // ピッカーの高さ
    let pickerBackgroundColor: Color = .gray.opacity(0.7) // 背景色
    let pickerCornerRadius: CGFloat = 8            // 角丸
    let pickerFont: Font = .title               // 文字サイズ
    let pickerTextColor: Color = .white             // 文字色

    var body: some View {
        ZStack {
            Color(red: 0.3, green: 0.4, blue: 0.8) // 背景色を指定
                .ignoresSafeArea() // セーフエリアも含めて塗りつぶす
            VStack(spacing: 16) {
                // MARK: - アニメーション表示用オーバーレイ
                if showLottie {
                    GeometryReader { geometry in
                        ZStack {
                            // 背景を暗くし、座席などを見えなくする
                            Color.black.opacity(0.6)
                                .ignoresSafeArea()

                            // 中央にLottieアニメーション表示
                            LottieView(animationName: "firework") // JSONファイル名(拡張子なし)
                                .frame(
                                    width: geometry.size.width * 0.5,
                                    height: geometry.size.height * 0.5
                                )
                                .scaleEffect(1.2)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                        .transition(.scale)
                        .zIndex(1) // 最前面
                    }
                }

                // MARK: - タイトル追加
                Text("2025年 管理部 & 経営企画室 歓迎会")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top)

                if !showLottie {
                    HStack(){
                        // MARK: - 部署選択
                        Picker("部署", selection: $manager.selectedDepartment) {
                            ForEach(manager.departments, id: \.self) { dept in
                                Text(dept)
                                    .font(pickerFont)
                                    .bold()
                                    .foregroundColor(pickerTextColor)
                                    .tag(dept)
                            }
                        }
                        .onChange(of: manager.selectedDepartment) {
                            manager.selectedMember = nil
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: pickerWidth, height: pickerHeight)
                        .padding()
                        .background(manager.selectedDepartment.isEmpty ? Color.gray.opacity(0.9) : Color.green.opacity(0.9)) // 状態に応じた背景色
                        .cornerRadius(pickerCornerRadius)

                        // MARK: - 氏名選択
                        if !manager.selectedDepartment.isEmpty && !manager.membersInSelectedDepartment.isEmpty {
                            Picker("名前", selection: $manager.selectedMember) {
                                ForEach(manager.membersInSelectedDepartment, id: \.self) { member in
                                    Text(member.name)
                                        .font(pickerFont)
                                        .bold()
                                        .foregroundColor(pickerTextColor)
                                        .tag(member as Member?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: pickerWidth, height: pickerHeight)
                            .padding()
                            .background(manager.selectedMember == nil ? Color.gray.opacity(0.9) : Color.green.opacity(0.9)) // 状態に応じた背景色
                            .cornerRadius(pickerCornerRadius)
                        }
                    }

                    // MARK: - くじ引きボタン
                    Button(action: {
                        if let member = manager.selectedMember {
                            // 座席割り当て
                            manager.assignRandomSeat(to: member)
                            manager.selectedMember = nil

                            // アニメーション表示
                            showLottie = true

                            // 前回のくじ引きの赤をリセットして新しい人を保存
                            lastAssignedMemberID = member.id

                            // アニメ終了（3.5秒後）
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                showLottie = false
                            }
                        }
                    }) {
                        Text("🎯 くじを引く")
                            .font(.title2)
                            .bold()
                            .frame(width: 160, height: 60)
                            .background(manager.selectedMember != nil ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(manager.selectedMember == nil)

                    // MARK: - 座席表
                    Text("座席表")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    // 座席表を5列のグリッドで表示（列数や間隔は変更可能）
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                        // 各座席に対して繰り返し表示
                        ForEach(manager.seats) { seat in
                            VStack(spacing: 4) {
                                // 座席番号表示
                                Text("No.\(seat.id)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                // メンバーが割り当てられている場合、その情報を表示
                                if let member = seat.member {
                                    Text("\(member.department) / \(member.name)")
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2) // 名前が長くても2行までに制限
                                } else {
                                    // 空席の場合の表示
                                    Text("空席")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            // 座席1つ分のサイズ設定（必要に応じて調整可能）
                            .frame(width: 56, height: 30)
                            .padding(6)
                            // メンバーがいるかどうかで背景色を変更（空席＝白、割り当て済み＝緑）
                            .background(
                                (seat.member?.id == lastAssignedMemberID && lastAssignedMemberID != nil)
                                ? Color.red.opacity(0.9)
                                : (seat.member == nil ? Color.white : Color.green.opacity(0.8))
                            )
                            .cornerRadius(8)
                            // 枠線（グレー）を追加して見やすくする
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }

    /// SwiftUI 上で Lottie アニメーションを表示するための UIViewRepresentable ラッパー
    struct LottieView: UIViewRepresentable {
        /// 再生する Lottie アニメーションのファイル名（.json 拡張子なし）
        let animationName: String
        /// UIView を作成し、Lottie アニメーションを設定して返す
        func makeUIView(context: Context) -> some UIView {
            let view = UIView()
            // Lottie アニメーションビューのインスタンスを作成
            let animationView = LottieAnimationView(name: animationName)
            // アニメーションのスケーリングモードを設定
            animationView.contentMode = .scaleAspectFit
            // 1回のみ再生する設定
            animationView.loopMode = .playOnce
            // アニメーションを再生
            animationView.play()
            // AutoLayout の使用を明示
            animationView.translatesAutoresizingMaskIntoConstraints = false
            // アニメーションビューを親ビューに追加
            view.addSubview(animationView)
            // 親ビューいっぱいにアニメーションを配置（上下左右）
            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: view.topAnchor),
                animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            return view
        }
        /// UIView の更新処理（ここでは使用しないため空実装）
        func updateUIView(_ uiView: UIViewType, context: Context) {}
    }
}

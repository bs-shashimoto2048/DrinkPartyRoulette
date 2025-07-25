// ProjectName: DrinkPartyRoulette
// Script Name: ContentView.swift
//  Created by 橋本諭 on 2025/07/25.
///　アニメーションのJSOnファイルは  https://lottiefiles.com/ にて入手

// MARK: - 部署選択〜くじ引き、座席(グリッド)画面
/// - LazyVGrid を使って 座席表を作成
/// - ボタンを押すたびに、選ばれた人がランダムな空席に入ります
/// - 割り当てられた席は 緑色、空席は 白 に表示
/// - 一部、アイコンなどの引数をiPad用へ変更、元の値はコメントアウトを参照

import SwiftUI
import Lottie // Package のインストールが必要

struct ContentView: View {
    @StateObject private var manager = SeatManager()

    @State private var showLottie = false
    @State private var resultText: String = ""
    // 前回くじ引きされたメンバーを追跡
    @State private var lastAssignedMemberID: Int? = nil

    // MARK: - ピッカー用のカスタマイズパラメータ
    let pickerWidth: CGFloat = 80*2                 // ピッカーの幅:80
    let pickerHeight: CGFloat = 20*2                 // ピッカーの高さ:20
    let pickerBackgroundColor: Color = .gray.opacity(0.7) // 背景色
    let pickerCornerRadius: CGFloat = 8*2            // 角丸
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
                            LottieView(animationName: "anime_heart") // JSONファイル名(拡張子なし)
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

                // MARK: - タイトル
                Text("2025年 管理部 & 経営企画室 歓迎会")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top)

                // MARK: - アイコンとセリフ
                HStack(alignment: .top, spacing: 10) {

                    // セリフ
                    Text(showLottie ? "なにが出るべしかな〜？" : {
                        if let selectedMember = manager.selectedMember {
                            // 特定のメンバーIDの場合にセリフを変更
                            if selectedMember.id == 1 { // 例: IDが1のメンバーが選ばれた場合
                                return "社長どの！\nお疲れ様ですべし！\nクジを引いて下さいべし！"
                            } else if selectedMember.id == 2 { // IDが2のメンバーが選ばれた場合
                                return "これはこれは専務どの！\nお疲れ様ですべし！\nクジを引いて下さいべし！"
                            } else if selectedMember.id == 32 { // IDが3のメンバーが選ばれた場合
                                return "おっ、あっくんだべしw\nおつべしw\nクジを引くべしよ〜！"
                            } else if selectedMember.id == 4 { // IDが4のメンバーが選ばれた場合
                                return "ボクの作者様だべし！\nいつもお仕事お疲れ様べし！\nさぁクジを引くべしよ〜！"
                            }
                        }
                        return "お疲れ様べし。\n自分の部署と名前を選んで\nクジを引くべしよ〜！"
                    }())
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(5)  // 行間を少し広げて読みやすく
                    .multilineTextAlignment(.leading) // テキストを左揃え
                    .fixedSize(horizontal: false, vertical: true) // テキストが長くても折り返す
                    .padding(.top, 10) // アイコンとセリフの間に少しスペースを追加

                    // アイコン画像 -> forResource(ファイル名) bs:通常ver, bs_1:飲酒ver
                    if let url = Bundle.main.url(forResource: "bs_1", withExtension: "png"),
                       let uiImage = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 150, height: 150) //(width: 100, height: 100)
                    }
                }

                if !showLottie {
                    HStack(){
                        // MARK: - 部署選択
                        Picker("部署", selection: $manager.selectedDepartment) {
                            ForEach(manager.departments, id: \.self) { dept in
                                Text(dept)
                                    .font(pickerFont)
                                    .bold()
                                    .foregroundColor(.black) // -> Default: pickerTextColor
                                    .tag(dept)
                            }
                        }
                        .onChange(of: manager.selectedDepartment) {
                            manager.selectedMember = nil
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: pickerWidth - 10, height: pickerHeight)
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
                                        .foregroundColor(.black) // -> Default: pickerTextColor
                                        .tag(member as Member?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: pickerWidth - 10, height: pickerHeight)
                            .padding()
                            .background(manager.selectedMember == nil ? Color.gray.opacity(0.9) : Color.green.opacity(0.9)) // 状態に応じた背景色
                            .cornerRadius(pickerCornerRadius)
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

                                // アニメ終了: (deadline: .now() + *.*) -> *.* で秒数指定
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    showLottie = false
                                }
                            }
                        }) {
                            Text("🎯くじを引く")
                                .font(.title3)
                                .bold()
                                .frame(width: 100*2, height: 40*2) // (width: 120, height: 50*2)
                                .background(manager.selectedMember != nil ? Color.green : Color.gray)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        .disabled(manager.selectedMember == nil)
                    }

                    // MARK: - ラベル：座席表
                    Text("座席表")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    // MARK: - 座席表を表示：5列のグリッド（列数や間隔は変更可能）
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        // 各座席に対して繰り返し表示
                        ForEach(manager.seats) { seat in
                            let bgColor: Color = {
                                if seat.member?.id == lastAssignedMemberID && lastAssignedMemberID != nil {
                                    return Color.red.opacity(0.9)
                                } else if let member = seat.member, manager.vipIDs.contains(member.id) {
                                    return Color(hue: 210/360, saturation: 0.6, brightness: 0.85) // VIPメンバーが着席中
                                } else if seat.member == nil && manager.vipSeatIDs.contains(seat.id) {
                                    return Color(hue: 210/360, saturation: 0.4, brightness: 0.95) // ★ 空席のVIP座席 → 薄い青
                                } else if seat.member == nil {
                                    return Color.white
                                } else {
                                    return Color.green.opacity(0.8)
                                }
                            }()


                            VStack(spacing: 4) {
                                // 座席ナンバー
                                Text("No.\(seat.id)")
                                    .font(.headline) //.caption
                                    .foregroundColor(.secondary)
                                // 指名
                                if let member = seat.member {
                                    Text("\(member.department) / \(member.name)")
                                        .font(.title2) //.caption2
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                } else {
                                    Text("空席")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 56*2, height: 40) //幅 56pt、高さ 30pt
                            .padding(6*2) //周囲に6ptの余白
                            .background(bgColor) //ビューの背景色を bgColor で指定
                            .cornerRadius(8*2) //ビューの 角を8ptの半径で丸める
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4))) //
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

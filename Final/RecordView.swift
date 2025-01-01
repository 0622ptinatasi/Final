//
//  RecordView.swift
//  Final
//
//  Created by user12 on 2024/12/5.
//

import SwiftUI
import SwiftData
import PhotosUI
import TipKit
struct SearchTip: Tip {
    var title: Text {
        Text("手帳紀錄")
    }
    
    var message: Text? {
        Text("使用搜尋功能快速尋找您的日常記錄。")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}
struct RecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isShowingOverlay = false // 控制模板顯示
    @State private var searchText: String = ""
    private var searchTip = SearchTip()

    var body: some View {
        ZStack {
            NavigationView {
                Group {
                    if filteredItems.isEmpty {
                        ContentUnavailableView("No Records Found", systemImage: "magnifyingglass")
                    } else {
                        List {
                            ForEach(filteredItems) { item in
                                NavigationLink(destination: DetailView(item: item)) {
                                    Text(item.title)
                                        .font(.headline)
                                }
                            }
                            .onDelete(perform: deleteItems) // 將 .onDelete 附加到 ForEach
                        }
                    }
                }
                .navigationTitle("Records")
                //.popoverTip(searchTip, arrowEdge: .top)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isShowingOverlay = true }) {
                            Label("Add Record", systemImage: "plus")
                                .foregroundColor(Color(hue: 0.077, saturation: 0.278, brightness: 0.866))
                                //.popoverTip(searchTip, arrowEdge: .top)
                        }
                        
                    }
                    
                }
                .popoverTip(searchTip, arrowEdge: .top)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search titles...")
            }

            if isShowingOverlay {
                Color.black.opacity(0.4) // 半透明背景遮罩
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 點擊背景關閉
                        isShowingOverlay = false
                    }

                AddRecordOverlay(isShowingOverlay: $isShowingOverlay)
                    .transition(.scale) // 彈出動畫
            }
        }

        }
        /// 過濾後的資料清單
        private var filteredItems: [Item] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { $0.title.contains(searchText) }
            }
        }

        private func deleteItems(offsets: IndexSet) {
            withAnimation {
                for index in offsets {
                    modelContext.delete(items[index])
                }
            }
        }
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter
        }()
}
struct AddRecordOverlay: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isShowingOverlay: Bool // 控制模板顯示與隱藏
    
    // 表單輸入資料
    @State private var startDate: Date = Date() // 開始日期
    @State private var endDate: Date = Date()   // 結束日期
    
    // 下拉式選單資料
    @State private var yearSelection: String = "2024" // 年
    @State private var monthSelection: String = "January"  // 月
    @State private var weekSelection: String = "week1"    // 週數
    
    @State private var textField1: String = ""  // 第一個文字輸入
    @State private var textField2: String = ""  // 第二個文字輸入
    @State private var textField3: String = ""  // 第三個文字輸入
    @State private var textField4: String = ""  // 第四個文字輸入
    @State private var selectedImage: UIImage? = nil // 照片
    
    // 照片選擇狀態
    @State private var isShowingImagePicker = false
    
    let months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]
    let weeks = ["week1","week2","week3","week4","week5"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Record")
                .font(.headline)
                .padding()
            
            // 日期選擇
            DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
            DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
            
            // Year Picker
            HStack {
                Text("Year")
                    .frame(maxWidth: .infinity, alignment: .leading) // 左對齊，並擴展到最大寬度
                Picker("Year", selection: $yearSelection) {
                    ForEach(2024..<2027, id: \.self) { year in
                        Text("\(year)").tag("\(year)")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.black)
                .background(Color.gray.opacity(0.1)) // 增加灰色背景（可調整透明度）
                .cornerRadius(8) // 圓角效果（可選）
                .frame(maxWidth: .infinity, alignment: .trailing) // 右對齊，並擴展到最大寬度
                
            }
            
            // Month Picker
            HStack{
                Text("Month")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Month", selection: $monthSelection) {
                    ForEach(months, id: \.self) { month in
                        Text(month).tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.black)
                .background(Color.gray.opacity(0.1)) // 增加灰色背景（可調整透明度）
                .cornerRadius(8) // 圓角效果（可選）
                .frame(maxWidth: .infinity,alignment: .trailing) // 設定最大寬度並左對齊
                .clipped()
            }
            
            // Week Picker
            HStack{
                Text("Week")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Picker("Week", selection: $weekSelection) {
                    ForEach(weeks, id: \.self) { week in
                        Text(week).tag(week)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(.black)
                .background(Color.gray.opacity(0.1)) // 增加灰色背景（可調整透明度）
                .cornerRadius(8) // 圓角效果（可選）
                .frame(maxWidth: .infinity,alignment: .trailing) // 設定最大寬度並左對齊
                .clipped()
            }
            // 按鈕區域
            HStack {
                Button(action: {
                    isShowingOverlay = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: saveRecord) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(maxWidth: 300) // 控制彈出框寬度
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    
    private func saveRecord() {
        withAnimation {
            // 計算日期區間，將時間部分設置為當天的開始
            let calendar = Calendar.current
            var currentDate = calendar.startOfDay(for: startDate)
            let adjustedEndDate = calendar.startOfDay(for: endDate)
            var dateModels: [DateModel] = [] // 儲存日期及對應的文字欄位

            repeat {
                // 建立新的 DateModel
                let dateModel = DateModel(
                    date: currentDate,
                    descript: "", // 替換為用戶的實際輸入
                    todoItems: [],
                    events: []
                )
                dateModels.append(dateModel)

                // 更新至下一天
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                    break // 如果無法計算出下一天，提早結束迴圈
                }
                currentDate = nextDate
            } while currentDate <= adjustedEndDate
            
            // 格式化日期範圍作為標題
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd"
                    let title: String
                    if let formattedStartDate = dateFormatter.string(for: startDate),
                       let formattedEndDate = dateFormatter.string(for: endDate) {
                        title = "\(formattedStartDate) ~ \(formattedEndDate)"
                    } else {
                        title = "No Dates Available"
                    }

            // 建立新紀錄
            let newItem = Item(
                timestamp: Date(),
                title: title,
                details: "\(yearSelection), \(monthSelection),  \(weekSelection)",
                gratitudes: textField1,
                reflections: textField2,
                treature: textField3,
                music: textField4,
                startDate: startDate,
                endDate: endDate,
                image: selectedImage,
                dateModels: dateModels
            )

            // 插入到模型
            modelContext.insert(newItem)
            isShowingOverlay = false
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // 僅限選擇圖片
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}


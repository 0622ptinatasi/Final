import SwiftUI
import SwiftData
import Foundation
import Charts
import MarkdownUI

struct CurrentView: View {
    @Query private var dateModels: [DateModel] // 動態篩選交給手動篩選處理

    @Environment(\.modelContext) private var modelContext

    @State private var newTaskTitle: String = "" // 儲存新增的待辦事項標題
    @State private var newEventDate: Date = Date() // 行程的日期時間
    @State private var newEventDescription: String = "" // 行程描述
    @State private var isAddingEvent: Bool = false // 控制顯示行程輸入框
    @State private var newDateDescription: String = "" // 儲存新增的日期描述文字
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @State private var selectedDateEvents: [Event] = []
    @State private var selectedDateTodoItems: [TodoItem] = []
    @State private var savedDateDescription: String = ""
    @State private var isEditingDiary: Bool = false
    @State private var eventToDelete: Event? = nil // 保存被選中的事件
    @State private var showDeleteConfirmation = false // 控制刪除框的顯示
    @State private var selectedImageURL: URL? = nil // 用于存储选中的图案 URL
    @State private var position: CGPoint = CGPoint(x: 150, y: 200) // 图案的初始位置
    @State private var isSearchBoxVisible: Bool = false // 控制搜索框的显示

    var body: some View {
        ZStack {
            // 主內容
            VStack {
                VStack(spacing: 5) {
                    Text("Today's To-Do List")
                        .font(.largeTitle)
                        .bold()

                    Button(action: {
                        isDatePickerPresented.toggle()
                    }) {
                        Text("Date: \(formattedDate(selectedDate))")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()

                HStack(alignment: .top, spacing: 5) {
                    leftSection
                        .frame(maxWidth: .infinity)

                    Divider()
                        .frame(width: 1)
                        .foregroundColor(.gray)

                    rightSection
                        .frame(maxWidth: .infinity)
                }

            }
            .frame(maxWidth: .infinity)
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        isSearchBoxVisible.toggle() // 切换搜索框显示状态
                    }) {
                        Text("+pic")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
            if let selectedImageURL = selectedImageURL {
                // 显示选中的图案并支持拖动
                if let uiImage = fetchUIImage(from: selectedImageURL) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .position(position) // 使用位置更新图片的显示位置
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // 实时更新位置
                                    position = value.location
                                }
                                .onEnded { value in
                                    // 最终确定的位置
                                    position = value.location
                                }
                        )
                }


            }
            
            // 浮動視窗
            if isAddingEvent {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)

                floatingEventInput
                    .transition(.scale)
            }

            // 日期選擇器彈窗
            if isDatePickerPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isDatePickerPresented = false
                    }

                VStack(spacing: 20) {
                    Text("Select Date")
                        .font(.headline)

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())

                    Button("Done") {
                        onDatePicked(selectedDate)
                        isDatePickerPresented = false
                    }
                    .padding()
                    .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
            }
            // 搜索框界面
            if isSearchBoxVisible {
                VStack {
                    TestView { selectedURL in
                        // 选择图片后的回调
                        selectedImageURL = selectedURL
                        position = CGPoint(x: 150, y: 200) // 重置位置
                        isSearchBoxVisible = false // 关闭搜索框
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5)) // 添加背景遮罩
                }
                //.ignoresSafeArea()
            }
        }
        .animation(.easeInOut, value: isAddingEvent)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Event"),
                message: Text("Are you sure you want to delete this event?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let event = eventToDelete {
                        deleteEvent(event)
                        eventToDelete = nil
                    }
                },
                secondaryButton: .cancel {
                    eventToDelete = nil
                }
            )
        }

    }

    private var leftSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                isAddingEvent.toggle()
            }) {
                Label("Add Event", systemImage: "calendar.badge.plus")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // 顯示選擇日期的行程
            GanttChartView(eventToDelete: $eventToDelete,
                           showDeleteConfirmation: $showDeleteConfirmation,events: selectedDateEvents)
        }
        .padding()
    }

    private var floatingEventInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add a New Event")
                .font(.headline)

            DatePicker("", selection: $newEventDate, displayedComponents: [.date, .hourAndMinute])
                .padding(.leading, -50.0)
                .datePickerStyle(CompactDatePickerStyle())

            TextField("Event Description", text: $newEventDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)

            HStack {
                Button("Cancel") {
                    isAddingEvent = false
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Save Event") {
                    addEvent()
                    isAddingEvent = false
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
        .padding()
    }

    private var rightSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 顯示當天的待辦事項
            if let todayDateModel = getDateModel(for: selectedDate) {
                if todayDateModel.todoItems.isEmpty {
                    Text("No tasks for today!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                } else {
                    TodoProgressChartView(todoItems: todayDateModel.todoItems)
                    ForEach(todayDateModel.todoItems, id: \.id) { todo in
                        HStack {
                            Text(todo.title)
                                .strikethrough(todo.isCompleted, color: .gray)
                                .foregroundColor(todo.isCompleted ? .gray : .black)

                            Spacer()

                            Button(action: {
                                todo.isCompleted.toggle()
                            }) {
                                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(todo.isCompleted ? .brown : .gray)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else {
                Text("No tasks for today!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            VStack {
                TextField("Enter a new task...", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    addNewTodo()
                }) {
                    Label("Add Task", systemImage: "plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)

            VStack {
                if savedDateDescription.isEmpty {
                    // 日记为空时显示输入框
                    TextEditor(text: $newDateDescription)
                           .frame(height: 150) // 设置高度
                           .padding()
                           .background(Color(.systemGray6))
                           .cornerRadius(8)
                           .overlay(
                               RoundedRectangle(cornerRadius: 8)
                                   .stroke(Color.gray, lineWidth: 1)
                           )
                    Button(action: {
                        saveDateDescription() // 使用已定义的存档函数
                        savedDateDescription = newDateDescription // 更新显示内容
                    }) {
                        Label("Save Diary", systemImage: "checkmark")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    // 显示 Markdown 渲染的日记内容
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Diary")
                            .font(.headline)

                        // 使用 MarkdownUI 的 Markdown 组件来渲染 Markdown 内容
                        Markdown(savedDateDescription)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        Button(action: {
                            // 切换回编辑模式并载入现有内容
                            newDateDescription = savedDateDescription
                            savedDateDescription = ""
                        }) {
                            Label("Edit Diary", systemImage: "pencil")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hue: 0.077, saturation: 0.278, brightness: 0.866))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)

        }
        .padding()
    }

    private func getDateModel(for date: Date) -> DateModel? {
        dateModels.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }


    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func addEvent() {
        guard !newEventDescription.isEmpty else {
            print("Event description is empty. No action taken.")
            return
        }

        let newEvent = Event(eventDate: newEventDate, eventDescription: newEventDescription)

        // 根據 floatingEventInput 裡的日期 (newEventDate) 獲取或創建 DateModel
        if let existingDateModel = getDateModel(for: newEventDate) {
            // 如果該日期已存在，新增事件
            existingDateModel.events.append(newEvent)
        } else {
            // 如果該日期尚無模型，創建新模型並插入事件
            let newDateModel = DateModel(
                date: newEventDate,
                descript: "",
                events: [newEvent]
            )
            modelContext.insert(newDateModel)
        }

        // 保存上下文
        do {
            try modelContext.save()
            print("Event saved for date \(formattedDate(newEventDate))")
        } catch {
            print("Failed to save event: \(error)")
        }

        // 清空輸入框
        newEventDescription = ""
        newEventDate = Date()

        // 更新視圖 (僅當前選擇的日期與 newEventDate 相同時更新)
        if Calendar.current.isDate(selectedDate, inSameDayAs: newEventDate) {
            refreshSelectedDateEvents()
        }
    }


    private func addNewTodo() {
        guard !newTaskTitle.isEmpty else { return }

        let newTodo = TodoItem(title: newTaskTitle)

        // 獲取或創建對應的 DateModel
        if let todayDateModel = getDateModel(for: selectedDate) {
            todayDateModel.todoItems.append(newTodo)
        } else {
            let newDateModel = DateModel(
                date: selectedDate,
                descript: "",
                todoItems: [newTodo],
                events: []
            )
            modelContext.insert(newDateModel)
        }

        // 保存上下文
        newTaskTitle = ""
        // 更新視圖 (僅當前選擇的日期與 newEventDate 相同時更新)
        if Calendar.current.isDate(selectedDate, inSameDayAs: newEventDate) {
            refreshSelectedDateEvents()
        }
    }


    private func saveDateDescription() {
        guard !newDateDescription.isEmpty else { return }

        // 獲取或創建對應的 DateModel
        if let todayDateModel = getDateModel(for: selectedDate) {
            todayDateModel.descript = newDateDescription
        } else {
            let newDateModel = DateModel(
                date: selectedDate,
                descript: newDateDescription,
                todoItems: [],
                events: []
            )
            modelContext.insert(newDateModel)
        }

        // 保存上下文
        savedDateDescription = newDateDescription
        // 更新視圖 (僅當前選擇的日期與 newEventDate 相同時更新)
        if Calendar.current.isDate(selectedDate, inSameDayAs: newEventDate) {
            refreshSelectedDateEvents()
        }
    }
    // 處理刪除邏輯
    private func deleteEvent(_ event: Event) {
        // 從資料庫中刪除
        if let dateModel = getDateModel(for: selectedDate) {
            if let index = dateModel.events.firstIndex(where: { $0.id == event.id }) {
                dateModel.events.remove(at: index)
            }
        }

        do {
            try modelContext.save()
            print("Event deleted: \(event.eventDescription)")
        } catch {
            print("Failed to delete event: \(error)")
        }

        // 更新當前選擇日期的事件
        refreshSelectedDateEvents()
    }

    private func onDatePicked(_ newDate: Date) {
        selectedDate = newDate
        refreshSelectedDateEvents()
        refreshSelectedDateTodoItems()
        refreshSelectedDateDiary()
    }
    private func refreshSelectedDateEvents() {
        if let dateModel = getDateModel(for: selectedDate) {
            selectedDateEvents = dateModel.events
        } else {
            selectedDateEvents = []
        }
    }
    private func refreshSelectedDateTodoItems() {
        if let dateModel = getDateModel(for: selectedDate) {
            // 更新當前日期的待辦事項
            selectedDateTodoItems = dateModel.todoItems
        } else {
            // 如果沒有模型，清空待辦事項
            selectedDateTodoItems = []
        }
    }
    private func refreshSelectedDateDiary() {
        if let dateModel = getDateModel(for: selectedDate) {
            // 更新日記內容
            savedDateDescription = dateModel.descript
            newDateDescription = "" // 確保輸入框清空
        } else {
            // 如果沒有日記內容，清空顯示
            savedDateDescription = ""
            newDateDescription = "" // 初始化輸入框
        }
    }
    // 加载 UIImage 用于在 Canvas 中绘制
    private func fetchUIImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

}

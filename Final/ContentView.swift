//
//  ContentView.swift
//  Final
//
//  Created by user12 on 2024/12/5.

import SwiftUI
import SwiftData
import PhotosUI
import TipKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TabView {
            /*TestView()
                .tabItem {
                    Label("Current", systemImage: "clock")
                }*/
            CurrentView()
                .tabItem {
                    Label("Current", systemImage: "clock")
                }
            
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "book")
                }
        }
        .accentColor(Color(hue: 0.077, saturation: 0.356, brightness: 0.72)) // 設置選中時的顏色
        .ignoresSafeArea() // 忽略安全區域
    }
    
}

struct DetailView: View {
    @Environment(\.modelContext) private var modelContext

    var item: Item
    @State private var isEditing = false

    // 編輯中的文字狀態
    @State private var editedDetails: String = ""
    @State private var editedGratitudes: String = ""
    @State private var editedReflections: String = ""
    @State private var editedTreature: String = ""
    @State private var editedMusic: String = ""
    @State private var selectedImage: UIImage? = nil // 用於存儲選擇的圖片
    @State private var isShowingImagePicker = false // 控制是否顯示圖片選擇器
    @State private var editedDateModels: [DateModel] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Timestamp: \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Start Date: \(formattedDate(item.startDate))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("End Date: \(formattedDate(item.endDate))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isEditing {
                    Group {
                        Text("Details:")
                            .font(.headline)
                        TextField("Details", text: $editedDetails)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 10)

                        Text("Gratitudes:")
                            .font(.headline)
                        TextField("Gratitudes", text: $editedGratitudes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Reflections:")
                            .font(.headline)
                        TextField("Reflections", text: $editedReflections)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Treature:")
                            .font(.headline)
                        TextField("Treature", text: $editedTreature)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Text("Music:")
                            .font(.headline)
                        TextField("Music", text: $editedMusic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        if !editedDateModels.isEmpty {
                            ForEach(Array(editedDateModels.enumerated()), id: \.offset) { index, dateModel in
                                VStack(alignment: .leading) {
                                    Text(" \(formattedDate(dateModel.date))")
                                        .font(.headline)
                                    TextField("Diary", text: Binding(
                                        get: { dateModel.descript },
                                        set: { editedDateModels[index].descript = $0 }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                .padding(.bottom, 10)
                            }

                        }

                        Button(action: { isShowingImagePicker = true }) {
                            Text("Add Photo")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Group {
                        Text("Details: \(item.details)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Gratitudes: \(item.gratitudes)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Reflections: \(item.reflections)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Treature: \(item.treature)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Music: \(item.music)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !item.dateModels.isEmpty {
                            ForEach(item.dateModels, id: \.id) { dateModel in
                                VStack(alignment: .leading) {
                                    Text(" \(formattedDate(dateModel.date))")
                                        .font(.headline)
                                    Text(dateModel.descript) // 注意這裡使用的是 descript
                                        .font(.body)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 10)
                            }

                        }
                    }
                }

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.top, 10)
                } else if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding(.top, 10)
                } else {
                    Text("No image attached.")
                        .foregroundColor(.gray)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Detail")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                        isEditing = false
                    }
                } else {
                    Button("Edit") {
                        startEditing()
                    }
                }
            }
        }
        .onAppear {
            loadItemData()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }

    private func loadItemData() {
        editedDetails = item.details
        editedGratitudes = item.gratitudes
        editedReflections = item.reflections
        editedTreature = item.treature
        editedMusic = item.music
        if let imageData = item.imageData {
            selectedImage = UIImage(data: imageData)
        }
        editedDateModels = item.dateModels
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }

    private func saveChanges() {
        withAnimation {
            item.details = editedDetails
            item.gratitudes = editedGratitudes
            item.reflections = editedReflections
            item.treature = editedTreature
            item.music = editedMusic

            if let selectedImage = selectedImage {
                item.imageData = selectedImage.jpegData(compressionQuality: 0.8)
            }
            item.dateModels = editedDateModels // 保存新的日期模型

            try? modelContext.save()
        }
    }

    private func startEditing() {
        isEditing = true
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
    
        .task {
            try? Tips.resetDatastore()
            
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}

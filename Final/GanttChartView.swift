//
//  GanttChartView.swift
//  Final
//
//  Created by user12 on 2024/12/22.
//

import SwiftUI

struct GanttChartView: View {
    @Binding var eventToDelete: Event? // 用於回傳被選中的事件
    @Binding var showDeleteConfirmation: Bool // 控制刪除確認框的顯示
    let events: [Event] // 傳入的事件資料

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(8..<23, id: \.self) { hour in
                    HStack(alignment: .top) {
                        // 左側顯示小時
                        Text(String(format: "%02d:00", hour))
                            .frame(width: 60, alignment: .leading)
                            .padding(.vertical, 5)
                            .foregroundColor(.gray)

                        // 右側顯示對應的小時事件或空佔位符
                        VStack(alignment: .leading) {
                            let hourEvents = eventsForHour(hour)
                            ForEach(hourEvents) { event in
                                HStack {
                                    Text(event.eventDescription)
                                        .font(.body)
                                        .padding(5)
                                        .background(Color(hue: 0.077, saturation: 0.356, brightness: 0.72).opacity(0.2))
                                        .cornerRadius(5)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                showDeleteConfirmation = true
                                                eventToDelete = event
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .onTapGesture(count: 2) {
                                            showDeleteConfirmation = true
                                            eventToDelete = event
                                        }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 29) // 明確固定每一行高度
                }
            }
            .padding(.horizontal)
        }
    }

    // 篩選對應小時且日期為今天的事件
    private func eventsForHour(_ hour: Int) -> [Event] {
        events.filter {
            let calendar = Calendar.current
            let eventHour = calendar.component(.hour, from: $0.eventDate)
            return eventHour == hour
        }
    }
}






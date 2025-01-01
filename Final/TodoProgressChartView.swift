//
//  TodoProgressChartView.swift
//  Final
//
//  Created by user12 on 2024/12/23.
//

import SwiftUI
import Charts

struct TodoProgressChartView: View {
    let todoItems: [TodoItem]

    var body: some View {
        // 计算完成比例
        let totalCount = todoItems.count
        let completedCount = todoItems.filter { $0.isCompleted }.count
        let completedPercentage = totalCount > 0 ? (Double(completedCount) / Double(totalCount)) * 100 : 0

        VStack {
            // 使用 Swift Charts 显示条形图
            Chart {
                BarMark(
                    x: .value("Completion", completedPercentage),
                    y: .value("Status", "Completed")
                )
                .foregroundStyle(Color.brown)

                BarMark(
                    x: .value("Completion", 100 - completedPercentage),
                    y: .value("Status", "Incomplete")
                )
                .foregroundStyle(Color.gray.opacity(0.3))
            }
            .chartXAxis(.hidden) // 隐藏 X 轴以简化图表
            .chartYAxis(.hidden) // 隐藏 Y 轴以简化图表
            .frame(height: 50)

            // 显示完成百分比
            Text(String(format: "%.0f%% Completed", completedPercentage))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

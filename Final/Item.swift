//
//  Item.swift
//  Final
//
//  Created by user12 on 2024/12/5.
//

import Foundation
import SwiftData
import PhotosUI

@Model
final class Item {
    @Attribute var timestamp: Date
    @Attribute var title: String
    @Attribute var details: String
    @Attribute var gratitudes: String
    @Attribute var reflections: String
    @Attribute var treature: String
    @Attribute var music: String
    @Attribute var startDate: Date
    @Attribute var endDate: Date
    @Attribute var imageData: Data? // 照片將存為 Data 類型
    @Attribute var dateModels: [DateModel] // 使用新的 DateModel

    init(
        timestamp: Date,
        title:String,
        details: String,
        gratitudes: String,
        reflections: String,
        treature: String,
        music: String,
        startDate: Date,
        endDate: Date,
        image: UIImage? = nil,
        dateModels: [DateModel] = []
    ) {
        self.timestamp = timestamp
        self.title = title
        self.details = details
        self.gratitudes = gratitudes
        self.reflections = reflections
        self.treature = treature
        self.music = music
        self.startDate = startDate
        self.endDate = endDate
        self.imageData = image?.jpegData(compressionQuality: 0.8)
        self.dateModels = dateModels
    }
}

@Model
final class DateModel {
    @Attribute var id: UUID // 每個日期的唯一標識
    @Attribute var date: Date // 具體的日期
    @Attribute var descript: String // 關於日期的文字描述
    @Relationship var todoItems: [TodoItem] // 與 TodoItem 的關聯
    @Attribute var events: [Event] // 新增的行程

    init(
        date: Date,
        descript: String,
        todoItems: [TodoItem] = [],
        events: [Event] = []
    ) {
        self.id = UUID()
        self.date = date
        self.descript = descript
        self.todoItems = todoItems
        self.events = events
    }
}

@Model
final class TodoItem {
    @Attribute var id: UUID // 每個待辦事項的唯一標識
    @Attribute var title: String // 待辦事項名稱
    @Attribute var isCompleted: Bool // 是否完成

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

@Model
final class Event {
    @Attribute var id: UUID
    @Attribute var eventDate: Date // 行程的日期時間
    @Attribute var eventDescription: String // 事件描述

    init(id: UUID = UUID(), eventDate: Date, eventDescription: String) {
        self.id = id
        self.eventDate = eventDate
        self.eventDescription = eventDescription
    }
}



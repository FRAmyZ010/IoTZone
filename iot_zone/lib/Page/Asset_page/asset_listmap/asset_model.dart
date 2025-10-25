import 'package:flutter/material.dart';

class AssetModel {
  final int id;
  final String type;
  final String name;
  final String status;
  final String image;
  final String description;
  final int statusColorValue;

  const AssetModel({
    required this.id,
    required this.type,
    required this.name,
    required this.status,
    required this.image,
    required this.description,
    required this.statusColorValue,
  });

  // 🔹 ใช้สำหรับแปลงจาก Map → Object (เช่น จาก DB หรือ JSON)
  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'] ?? 0,
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      statusColorValue: map['statusColorValue'] ?? Colors.grey.value,
    );
  }

  // 🔹 ใช้สำหรับแปลงจาก Object → Map (เก็บลง DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'status': status,
      'image': image,
      'description': description,
      'statusColorValue': statusColorValue,
    };
  }

  // 🔹 getter แปลง int → Color
  Color get statusColor => Color(statusColorValue);

  // 🔹 ใช้สำหรับ clone แล้วแก้บางค่า (เช่น toggle status)
  AssetModel copyWith({
    int? id,
    String? type,
    String? name,
    String? status,
    String? image,
    String? description,
    int? statusColorValue,
  }) {
    return AssetModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      status: status ?? this.status,
      image: image ?? this.image,
      description: description ?? this.description,
      statusColorValue: statusColorValue ?? this.statusColorValue,
    );
  }
}

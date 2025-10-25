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

  Color get statusColor => Color(statusColorValue);
}

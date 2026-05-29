import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class PasswordItem extends HiveObject {
  PasswordItem({
    required this.id,
    required this.appName,
    required this.username,
    required this.password,
    required this.category,
    required this.url,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String appName;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String url;

  @HiveField(6)
  final String notes;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  PasswordItem copyWith({
    String? appName,
    String? username,
    String? password,
    String? category,
    String? url,
    String? notes,
    DateTime? updatedAt,
  }) {
    return PasswordItem(
      id: id,
      appName: appName ?? this.appName,
      username: username ?? this.username,
      password: password ?? this.password,
      category: category ?? this.category,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PasswordItemAdapter extends TypeAdapter<PasswordItem> {
  @override
  final int typeId = 1;

  @override
  PasswordItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordItem(
      id: fields[0] as String,
      appName: fields[1] as String,
      username: fields[2] as String,
      password: fields[3] as String,
      category: fields[4] as String,
      url: fields[5] as String,
      notes: fields[6] as String,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.url)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}

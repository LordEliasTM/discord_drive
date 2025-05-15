// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderIndex _$FolderIndexFromJson(Map<String, dynamic> json) => FolderIndex(
      version: (json['version'] as num).toInt(),
      lastEdit: (json['lastEdit'] as num).toInt(),
      files: (json['files'] as List<dynamic>)
          .map((e) => FileEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      folders: (json['folders'] as List<dynamic>)
          .map((e) => FolderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FolderIndexToJson(FolderIndex instance) =>
    <String, dynamic>{
      'version': instance.version,
      'lastEdit': instance.lastEdit,
      'files': instance.files,
      'folders': instance.folders,
    };

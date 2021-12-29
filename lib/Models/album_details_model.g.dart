// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album_details_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumAdapter extends TypeAdapter<Album> {
  @override
  final int typeId = 0;

  @override
  Album read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Album(
      itemTitle: fields[0] as String?,
      itemArtist: fields[1] as String?,
      itemHref: fields[2] as String?,
      song: (fields[3] as List?)?.cast<Song>(),
    );
  }

  @override
  void write(BinaryWriter writer, Album obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemTitle)
      ..writeByte(1)
      ..write(obj.itemArtist)
      ..writeByte(2)
      ..write(obj.itemHref)
      ..writeByte(3)
      ..write(obj.song);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SongAdapter extends TypeAdapter<Song> {
  @override
  final int typeId = 1;

  @override
  Song read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Song(
      songImage: fields[0] as String?,
      songTitle: fields[1] as String?,
      songArtist: fields[2] as String?,
      songOfAlbum: fields[3] as String?,
      songDateRelease: fields[4] as String?,
      mp3Url128: fields[5] as String?,
      mp3Url320: fields[6] as String?,
      mp3Url500: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.songImage)
      ..writeByte(1)
      ..write(obj.songTitle)
      ..writeByte(2)
      ..write(obj.songArtist)
      ..writeByte(3)
      ..write(obj.songOfAlbum)
      ..writeByte(4)
      ..write(obj.songDateRelease)
      ..writeByte(5)
      ..write(obj.mp3Url128)
      ..writeByte(6)
      ..write(obj.mp3Url320)
      ..writeByte(7)
      ..write(obj.mp3Url500);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

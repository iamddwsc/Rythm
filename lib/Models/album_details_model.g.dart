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
      songSinger: fields[2] as String?,
      songWriter: fields[3] as String?,
      songOfAlbum: fields[4] as String?,
      songDateRelease: fields[5] as String?,
      mp3Url128: fields[6] as String?,
      mp3Url320: fields[7] as String?,
      mp3Url500: fields[8] as String?,
      lossless: fields[9] as String?,
    )..main_url = fields[10] as String?;
  }

  @override
  void write(BinaryWriter writer, Song obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.songImage)
      ..writeByte(1)
      ..write(obj.songTitle)
      ..writeByte(2)
      ..write(obj.songSinger)
      ..writeByte(3)
      ..write(obj.songWriter)
      ..writeByte(4)
      ..write(obj.songOfAlbum)
      ..writeByte(5)
      ..write(obj.songDateRelease)
      ..writeByte(6)
      ..write(obj.mp3Url128)
      ..writeByte(7)
      ..write(obj.mp3Url320)
      ..writeByte(8)
      ..write(obj.mp3Url500)
      ..writeByte(9)
      ..write(obj.lossless)
      ..writeByte(10)
      ..write(obj.main_url);
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

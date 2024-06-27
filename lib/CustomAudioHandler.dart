import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class CustomAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> play() async {
    print("CustomAudioHandler.play() called");
    await _player.resume();
    playbackState.add(playbackState.value
        .copyWith(playing: true, controls: [MediaControl.pause]));
  }

  @override
  Future<void> pause() async {
    print("CustomAudioHandler.pause() called");
    await _player.pause();
    playbackState.add(playbackState.value
        .copyWith(playing: false, controls: [MediaControl.play]));
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    print("CustomAudioHandler.playMediaItem() called with $mediaItem");
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.loading));
    await _player.setSourceUrl(mediaItem.id);
    await _player.resume();
    this.mediaItem.add(mediaItem);
    playbackState.add(playbackState.value.copyWith(
        playing: true,
        processingState: AudioProcessingState.ready,
        controls: [MediaControl.pause]));
  }
}

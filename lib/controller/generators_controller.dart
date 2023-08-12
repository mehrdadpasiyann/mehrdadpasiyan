import 'package:namida/class/track.dart';
import 'package:namida/controller/history_controller.dart';
import 'package:namida/controller/indexer_controller.dart';
import 'package:namida/controller/playlist_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/extensions.dart';

class NamidaGenerator {
  static NamidaGenerator get inst => _instance;
  static final NamidaGenerator _instance = NamidaGenerator._internal();
  NamidaGenerator._internal();

  Set<String> getHighMatcheFilesFromFilename(Iterable<String> files, String filename) {
    return files.where(
      (element) {
        final trackFilename = filename;
        final fileSystemFilenameCleaned = element.getFilename.cleanUpForComparison;
        final l = Indexer.inst.getTitleAndArtistFromFilename(trackFilename);
        final trackTitle = l.$1;
        final trackArtist = l.$2;
        final matching1 = fileSystemFilenameCleaned.contains(trackFilename.cleanUpForComparison);
        final matching2 = fileSystemFilenameCleaned.contains(trackTitle.split('(').first) && fileSystemFilenameCleaned.contains(trackArtist);
        return matching1 || matching2;
      },
    ).toSet();
  }

  List<Track> getRandomTracks([int? min, int? max]) {
    final trackslist = allTracksInLibrary;
    final trackslistLength = trackslist.length;

    if (trackslist.length < 3) {
      return [];
    }

    /// ignore min and max if the value is more than the alltrackslist.
    if (max != null && max > allTracksInLibrary.length) {
      max = null;
      min = null;
    }
    min ??= trackslistLength ~/ 12;
    max ??= trackslistLength ~/ 8;

    // number of resulting tracks.
    final int randomNumber = (max - min).getRandomNumberBelow(min);

    final Set<Track> randomList = {};
    for (int i = 0; i <= randomNumber; i++) {
      randomList.add(trackslist[trackslistLength.getRandomNumberBelow()]);
    }
    return randomList.toList();
  }

  List<Track> generateRecommendedTrack(Track track) {
    final historytracks = HistoryController.inst.historyTracks;
    if (historytracks.isEmpty) {
      return [];
    }
    const length = 10;
    final max = historytracks.length;
    int clamped(int range) => range.clamp(0, max);

    final Map<Track, int> numberOfListensMap = {};

    for (int i = 0; i <= historytracks.length - 1;) {
      final t = historytracks[i];
      if (t.track == track) {
        final heatTracks = historytracks.getRange(clamped(i - length), clamped(i + length)).toList();
        heatTracks.loop((e, index) {
          numberOfListensMap.update(e.track, (value) => value + 1, ifAbsent: () => 1);
        });
        // skip length since we already took 10 tracks.
        i += length;
      } else {
        i++;
      }
    }

    numberOfListensMap.remove(track);

    final sortedByValueMap = numberOfListensMap.entries.toList();
    sortedByValueMap.sortByReverse((e) => e.value);

    return sortedByValueMap.map((e) => e.key).toList();
  }

  /// if [maxCount == null], it will return all available tracks
  List<Track> generateTracksFromHistoryDates(DateTime? oldestDate, DateTime? newestDate) {
    if (oldestDate == null || newestDate == null) return [];

    final tracksAvailable = <Track>[];
    final entries = HistoryController.inst.historyMap.value.entries.toList();

    final oldestDay = oldestDate.millisecondsSinceEpoch.toDaysSinceEpoch();
    final newestDay = newestDate.millisecondsSinceEpoch.toDaysSinceEpoch();

    entries.loop((entry, index) {
      final day = entry.key;
      if (day >= oldestDay && day <= newestDay) {
        tracksAvailable.addAll(entry.value.toTracks());
      }
    });

    tracksAvailable.removeDuplicates((element) => element.path);

    return tracksAvailable;
  }

  /// [daysRange] means taking n days before [yearTimeStamp] & n days after [yearTimeStamp].
  ///
  /// For best results, track should have the year tag in [yyyyMMdd] format (or any parsable format),
  /// Having a [yyyy] year tag will generate from the same year which is quite a wide range.
  List<Track> generateTracksFromSameEra(int yearTimeStamp, {int daysRange = 30, Track? currentTrack}) {
    final tracksAvailable = <Track>[];

    // -- [yyyy] year format.
    if (yearTimeStamp.toString().length == 4) {
      allTracksInLibrary.loop((e, index) {
        if (e.year != 0) {
          // -- if the track also has [yyyy]
          if (e.year.toString().length == 4) {
            if (e.year == yearTimeStamp) {
              tracksAvailable.add(e);
            }

            // -- if the track has parsable format
          } else {
            final dt = DateTime.tryParse(e.year.toString());
            if (dt != null && dt.year == yearTimeStamp) {
              tracksAvailable.add(e);
            }
          }
        }
      });

      // -- parsable year format.
    } else {
      final dateParsed = DateTime.tryParse(yearTimeStamp.toString());
      if (dateParsed == null) return [];

      allTracksInLibrary.loop((e, index) {
        if (e.year != 0) {
          final dt = DateTime.tryParse(e.year.toString());
          if (dt != null && (dt.difference(dateParsed).inDays).abs() <= daysRange) {
            tracksAvailable.add(e);
          }
        }
      });
    }
    tracksAvailable.remove(currentTrack);
    return tracksAvailable;
  }

  Iterable<Track> generateTracksFromMoods(Iterable<String> playlistMoods, Iterable<String> tracksMoods) {
    final finalTracks = <Track>[];

    // --- Generating from Playlists.
    for (final pl in PlaylistController.inst.playlistsMap.entries) {
      if (pl.value.moods.any((e) => playlistMoods.contains(e))) {
        finalTracks.addAll(pl.value.tracks.tracks);
      }
    }

    /// --- Generating from all Tracks.
    Indexer.inst.trackStatsMap.forEach((key, value) {
      if (value.moods.any((element) => tracksMoods.contains(element))) {
        finalTracks.add(key);
      }
    });

    return finalTracks.uniqued();
  }

  List<Track> generateTracksFromRatings(
    int minRating,
    int maxRating,
  ) {
    final finalTracks = <Track>[];
    Indexer.inst.trackStatsMap.forEach((key, value) {
      if (value.rating >= minRating && value.rating <= maxRating) {
        finalTracks.add(key);
      }
    });
    return finalTracks;
  }
}

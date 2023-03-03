import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:namida/controller/settings_controller.dart';
import 'package:namida/controller/video_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/translations/strings.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/widgets/settings_card.dart';

class PlaybackSettings extends StatelessWidget {
  final bool disableSubtitle;
  const PlaybackSettings({super.key, this.disableSubtitle = false});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: Language.inst.PLAYBACK_SETTING,
      subtitle: disableSubtitle ? null : Language.inst.PLAYBACK_SETTING_SUBTITLE,
      icon: Broken.play_cricle,
      child: Column(
        children: [
          Obx(
            () => CustomSwitchListTile(
              title: Language.inst.ENABLE_VIDEO_PLAYBACK,
              icon: Broken.video,
              value: SettingsController.inst.enableVideoPlayback.value,
              onChanged: (p0) async => await VideoController.inst.toggleVideoPlaybackInSetting(),
            ),
          ),
          Obx(
            () => CustomListTile(
              title: Language.inst.VIDEO_PLAYBACK_SOURCE,
              icon: Broken.scroll,
              trailingText: SettingsController.inst.videoPlaybackSource.value.toText,
              onTap: () {
                bool isEnabled(int val) {
                  return SettingsController.inst.videoPlaybackSource.value == val;
                }

                void tileOnTap(int val) {
                  SettingsController.inst.save(videoPlaybackSource: val);
                }

                Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.VIDEO_PLAYBACK_SOURCE,
                    actions: [
                      IconButton(
                        onPressed: () => tileOnTap(0),
                        icon: const Icon(Broken.refresh),
                      ),
                      ElevatedButton(
                        onPressed: () => Get.close(1),
                        child: Text(Language.inst.DONE),
                      ),
                    ],
                    child: SizedBox(
                      width: Get.width,
                      height: Get.height / 2,
                      child: DefaultTextStyle(
                        style: context.textTheme.displaySmall!,
                        child: Obx(
                          () => ListView(
                            shrinkWrap: true,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "${Language.inst.AUTO}: ",
                                  style: context.textTheme.displayMedium,
                                  children: [
                                    TextSpan(
                                      text: Language.inst.VIDEO_PLAYBACK_SOURCE_AUTO_SUBTITLE,
                                      style: context.textTheme.displaySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: "${Language.inst.VIDEO_PLAYBACK_SOURCE_LOCAL}: ",
                                  style: context.textTheme.displayMedium,
                                  children: [
                                    TextSpan(
                                      text: "${Language.inst.VIDEO_PLAYBACK_SOURCE_LOCAL_SUBTITLE}, ${Language.inst.VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE}: ",
                                      style: context.textTheme.displaySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                Language.inst.VIDEO_PLAYBACK_SOURCE_LOCAL_EXAMPLE_SUBTITLE,
                                style: context.textTheme.displaySmall?.copyWith(fontSize: 10.0.multipliedFontScale, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              Text.rich(
                                TextSpan(
                                  text: "${Language.inst.VIDEO_PLAYBACK_SOURCE_YOUTUBE}: ",
                                  style: context.textTheme.displayMedium,
                                  children: [
                                    TextSpan(
                                      text: Language.inst.VIDEO_PLAYBACK_SOURCE_YOUTUBE_SUBTITLE,
                                      style: context.textTheme.displaySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 18.0,
                              ),
                              ListTileWithCheckMark(
                                active: isEnabled(0),
                                title: Language.inst.AUTO,
                                onTap: () => tileOnTap(0),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isEnabled(1),
                                title: Language.inst.VIDEO_PLAYBACK_SOURCE_LOCAL,
                                onTap: () => tileOnTap(1),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isEnabled(2),
                                title: Language.inst.VIDEO_PLAYBACK_SOURCE_YOUTUBE,
                                onTap: () => tileOnTap(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(
            () => CustomListTile(
              title: Language.inst.VIDEO_QUALITY,
              icon: Broken.story,
              trailingText: SettingsController.inst.youtubeVideoQualities.first,
              onTap: () {
                bool isEnabled(String val) {
                  return SettingsController.inst.youtubeVideoQualities.toList().contains(val);
                }

                void tileOnTap(String val, int index) {
                  if (isEnabled(val)) {
                    if (SettingsController.inst.youtubeVideoQualities.length == 1) {
                      Get.snackbar(Language.inst.MINIMUM_ONE_QUALITY, Language.inst.MINIMUM_ONE_QUALITY_SUBTITLE);
                    } else {
                      SettingsController.inst.removeFromList(youtubeVideoQualities1: val);
                    }
                  } else {
                    SettingsController.inst.save(youtubeVideoQualities: [val]);
                  }
                  // sorts and saves dec
                  SettingsController.inst.youtubeVideoQualities.sort((b, a) => kStockVideoQualities.indexOf(a).compareTo(kStockVideoQualities.indexOf(b)));
                  SettingsController.inst.save(youtubeVideoQualities: SettingsController.inst.youtubeVideoQualities.toList());
                }

                Get.dialog(
                  CustomBlurryDialog(
                    title: Language.inst.VIDEO_QUALITY,
                    actions: [
                      // IconButton(
                      //   onPressed: () => tileOnTap(0),
                      //   icon: const Icon(Broken.refresh),
                      // ),
                      ElevatedButton(
                        onPressed: () => Get.close(1),
                        child: Text(Language.inst.DONE),
                      ),
                    ],
                    child: SizedBox(
                      width: Get.width,
                      height: Get.height / 2,
                      child: DefaultTextStyle(
                        style: context.textTheme.displaySmall!,
                        child: Obx(
                          () => ListView(
                            shrinkWrap: true,
                            children: [
                              Text(Language.inst.VIDEO_QUALITY_SUBTITLE),
                              const SizedBox(
                                height: 12.0,
                              ),
                              Text("${Language.inst.NOTE}: ${Language.inst.VIDEO_QUALITY_SUBTITLE_NOTE}"),
                              const SizedBox(
                                height: 18.0,
                              ),
                              ...kStockVideoQualities
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => Column(
                                      children: [
                                        const SizedBox(
                                          height: 12.0,
                                        ),
                                        ListTileWithCheckMark(
                                          tileColor: Colors.transparent,
                                          active: isEnabled(e.value),
                                          title: e.value,
                                          onTap: () => tileOnTap(e.value, e.key),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(
            () => CustomSwitchListTile(
              leading: StackedIcon(
                baseIcon: Broken.play,
                secondaryIcon: Broken.pause,
                baseIconColor: context.theme.listTileTheme.iconColor,
                secondaryIconColor: context.theme.listTileTheme.iconColor,
              ),
              title: Language.inst.ENABLE_FADE_EFFECT_ON_PLAY_PAUSE,
              onChanged: (value) {
                SettingsController.inst.save(
                  enableVolumeFadeOnPlayPause: !value,
                );
              },
              value: SettingsController.inst.enableVolumeFadeOnPlayPause.value,
            ),
          ),
          Obx(
            () => CustomListTile(
              icon: Broken.timer,
              title: Language.inst.MIN_VALUE_TO_COUNT_TRACK_LISTEN,
              onTap: () => Get.dialog(
                CustomBlurryDialog(
                  title: Language.inst.CHOOSE,
                  child: Column(
                    children: [
                      Text(
                        Language.inst.MIN_VALUE_TO_COUNT_TRACK_LISTEN,
                        style: context.textTheme.displayLarge,
                      ),
                      const SizedBox(
                        height: 32.0,
                      ),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NamidaWheelSlider(
                              totalCount: 160,
                              initValue: SettingsController.inst.isTrackPlayedSecondsCount.value - 20,
                              itemSize: 6,
                              onValueChanged: (val) {
                                final v = (val + 20) as int;
                                SettingsController.inst.save(isTrackPlayedSecondsCount: v);
                              },
                              text: "${SettingsController.inst.isTrackPlayedSecondsCount.value}s",
                              topText: Language.inst.SECONDS,
                              textPadding: 8.0,
                            ),
                            Text(
                              Language.inst.OR,
                              style: context.textTheme.displayMedium,
                            ),
                            NamidaWheelSlider(
                              totalCount: 80,
                              initValue: SettingsController.inst.isTrackPlayedPercentageCount.value - 20,
                              itemSize: 6,
                              onValueChanged: (val) {
                                final v = (val + 20) as int;
                                SettingsController.inst.save(isTrackPlayedPercentageCount: v);
                              },
                              text: "${SettingsController.inst.isTrackPlayedPercentageCount.value}%",
                              topText: Language.inst.PERCENTAGE,
                              textPadding: 8.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              trailingText: "${SettingsController.inst.isTrackPlayedSecondsCount.value}s | ${SettingsController.inst.isTrackPlayedPercentageCount.value}%",
            ),
          ),
        ],
      ),
    );
  }
}
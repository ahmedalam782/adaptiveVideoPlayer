# Normal player names

Two designs. Edit the class with the matching prefix.

`Mobile` is phone only. `Responsive` is Windows, web, and tablet. Those widgets must keep working when the window gets narrower.

## Mobile (phone only)

| Class | File |
| --- | --- |
| `MobileControlsSurface` | `widgets/mobile/mobile_controls_surface.dart` |
| `MobilePlayerChrome` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileTopBar` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileCenterTransport` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobilePlayIcon` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileSkipButton` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileActionRow` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileLabeledAction` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileRoundIconButton` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileBrightnessSlider` | `widgets/mobile/mobile_player_chrome.dart` |
| `MobileScreenLockBadge` | `widgets/mobile/mobile_screen_lock_badge.dart` |
| `MobileNextEpisodePrompt` | `widgets/mobile/mobile_next_episode_prompt.dart` |

## Responsive (Windows, web, tablet)

| Class | File | What changes with width |
| --- | --- | --- |
| `ResponsiveFilledPanels` | `widgets/responsive/responsive_filled_panels.dart` | Phone and tablet open panels edge to edge. Wide desktop keeps floating popups. |
| `ResponsiveAudioSubtitlesPanel` | `widgets/adaptive_audio_subtitles_popup.dart` | `immersive` fills the player. Otherwise the card width and height follow the player. |
| `ResponsiveAudioSubtitleColumns` | `widgets/responsive/responsive_audio_subtitle_columns.dart` | Two columns share the available width. |
| `ResponsiveSubtitleOption` | `widgets/responsive/responsive_audio_subtitle_columns.dart` | One subtitle row. |
| `ResponsiveAudioOption` | `widgets/responsive/responsive_audio_subtitle_columns.dart` | One audio row. |
| `ResponsiveEpisodesPanel` | `widgets/adaptive_episodes_drawer.dart` | `horizontal` uses the rail. Otherwise a width-capped list. |
| `ResponsiveEpisodesRail` | `widgets/responsive/responsive_episodes_rail.dart` | Horizontal cards. Season menu when more than one season exists. |
| `ResponsiveEpisodeRailCard` | `widgets/responsive/responsive_episodes_rail.dart` | One episode card in the rail. |
| `ResponsiveEpisodeListCard` | `widgets/responsive/responsive_episode_list_card.dart` | One episode row in the wide list. |
| `ResponsiveNowPlayingEqualizer` | `widgets/responsive/responsive_episode_list_card.dart` | Now-playing bars on the wide list card. |
| `ResponsiveSpeedPanel` | `widgets/adaptive_speed_stepper_popup.dart` | `asSheet` is the full-width slider. Otherwise a card capped to the player width. |
| `ResponsiveSpeedSheet` | `widgets/adaptive_speed_stepper_popup.dart` | Bottom speed slider. |
| `AdaptiveBottomBar` | `widgets/adaptive_bottom_bar.dart` | Action icons scroll when the bar is narrow. |
| `AdaptiveInlineBottomBar` | `widgets/adaptive_inline_bottom_bar.dart` | Trailing icons scroll inside half the bar width. |

## Utils

| Class | File |
| --- | --- |
| `PlayerSurfaceTier` | `utils/player_surface_tier.dart` |
| `resolvePlayerSurfaceTier` | `utils/player_surface_tier.dart` |
| `PlayerSurfaceScope` | `utils/player_surface_tier.dart` |
| `playerSurfaceTierOf` | `utils/player_surface_tier.dart` |
| `PlayerChromeUtils` | `utils/player_chrome_utils.dart` |

Old names still work: `AdaptiveAudioSubtitlesPopup`, `AdaptiveEpisodesDrawer`, `AdaptiveSpeedStepperPopup`.

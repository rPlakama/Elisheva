{
  config,
  lib,
  ...
}:

let
  cfg = config.optionals.features.vesktop;
  user = config.core.user;
in
{
  options.mySystem.features.vesktop.enable = lib.mkEnableOption "Vesktop, a better Discord for Linux";

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.vesktop = {
        enable = true;
        settings = {
          discordBranch = "stable";
          minimizeToTray = true;
          spellCheckLanguages = [
            "en-US"
            "en"
            "br"
            "PT-br"
          ];
        };
        vencord = {
          settings = {
            notifyAboutUpdates = false;
            autoUpdate = true;
            autoUpdateNotification = false;
            useQuickCss = true;
            enableReactDevtools = false;
            frameless = false;
            transparent = false;
            winCtrlQ = false;
            disableMinSize = false;
            winNativeTitleBar = false;

            notifications = {
              timeout = 5000;
              position = "top-right";
              useNative = "not-focused";
              logLimit = 5;
            };

            cloud = {
              authenticated = false;
              url = "https://api.vencord.dev/";
              settingsSync = false;
              settingsSyncVersion = 174533173837;
            };

            eagerPatches = false;

            plugins = {
              BadgeAPI.enabled = true;
              ChatInputButtonAPI.enabled = true;
              CommandsAPI.enabled = true;
              ContextMenuAPI.enabled = true;
              MemberListDecoratorsAPI.enabled = true;
              MessageAccessoriesAPI.enabled = true;
              MessageDecorationsAPI.enabled = true;
              MessageEventsAPI.enabled = true;
              MessagePopoverAPI.enabled = true;
              NoticesAPI.enabled = true;
              ServerListAPI.enabled = true;
              SupportHelper.enabled = true;
              BetterGifAltText.enabled = true;
              BetterGifPicker.enabled = true;
              BetterUploadButton.enabled = true;
              ClearURLs.enabled = true;
              ColorSighted.enabled = true;
              CopyUserURLs.enabled = true;
              CrashHandler.enabled = true;
              DisableCallIdle.enabled = true;
              FavoriteEmojiFirst.enabled = true;
              FavoriteGifSearch.enabled = true;
              FixCodeblockGap.enabled = true;
              FixSpotifyEmbeds.enabled = true;
              FixYoutubeEmbeds.enabled = true;
              ForceOwnerCrown.enabled = true;
              FriendsSince.enabled = true;
              GreetStickerPicker.enabled = true;
              MessageTags.enabled = true;
              MoreKaomoji.enabled = true;
              NoF1.enabled = true;
              NoTypingAnimation.enabled = true;
              NoUnblockToJump.enabled = true;
              NSFWGateBypass.enabled = true;
              petpet.enabled = true;
              PreviewMessage.enabled = true;
              QuickReply.enabled = true;
              ReadAllNotificationsButton.enabled = true;
              ReverseImageSearch.enabled = true;
              Unindent.enabled = true;
              UrbanDictionary.enabled = true;
              ValidUser.enabled = true;
              VoiceMessages.enabled = true;
              WebKeybinds.enabled = true;
              WhoReacted.enabled = true;
              Wikisearch.enabled = true;
              UnlockedAvatarZoom.enabled = true;
              ValidReply.enabled = true;
              WebScreenShareFixes.enabled = true;
              MessageUpdaterAPI.enabled = true;
              ServerInfo.enabled = true;
              SettingsStoreAPI.enabled = true;
              NoOnboardingDelay.enabled = true;
              UserSettingsAPI.enabled = true;
              YoutubeAdblock.enabled = true;
              FullSearchContext.enabled = true;
              CopyFileContents.enabled = true;
              DynamicImageModalAPI.enabled = true;
              HideMedia.enabled = true;
              DisableDeepLinks.enabled = true;

              NoTrack = {
                enabled = true;
                disableAnalytics = true;
              };
              Settings = {
                enabled = true;
                settingsLocation = "aboveActivity";
              };
              AlwaysTrust = {
                enabled = true;
                domain = true;
                file = true;
              };
              BetterNotesBox = {
                enabled = true;
                hide = true;
                noSpellCheck = false;
              };
              BetterRoleContext = {
                enabled = true;
                roleIconFileFormat = "png";
              };
              BetterSettings = {
                enabled = true;
                disableFade = true;
                eagerLoad = true;
              };
              BlurNSFW = {
                enabled = true;
                blurAmount = 10;
              };
              Dearrow = {
                enabled = true;
                hideButton = false;
                replaceElements = 0;
                dearrowByDefault = true;
              };
              LoadingQuotes = {
                enabled = true;
                replaceEvents = true;
                enableDiscordPresetQuotes = false;
                additionalQuotes = "";
                additionalQuotesDelimiter = "|";
                enablePluginPresetQuotes = true;
              };
              MemberCount = {
                enabled = true;
                memberList = true;
                toolTip = true;
              };
              MessageLinkEmbeds = {
                enabled = true;
                listMode = "blacklist";
                idList = ",";
                automodEmbeds = "never";
              };
              NoPendingCount = {
                enabled = true;
                hideFriendRequestsCount = false;
                hideMessageRequestsCount = false;
                hidePremiumOffersCount = true;
              };
              OnePingPerDM = {
                enabled = true;
                channelToAffect = "both_dms";
                allowMentions = false;
                allowEveryone = false;
              };
              OpenInApp = {
                enabled = true;
                spotify = true;
                steam = true;
                epic = true;
                tidal = true;
                itunes = true;
              };
              PlatformIndicators = {
                enabled = true;
                colorMobileIndicator = true;
                list = true;
                badges = true;
                messages = true;
              };
              RelationshipNotifier = {
                enabled = true;
                offlineRemovals = true;
                groups = true;
                servers = true;
                friends = true;
                friendRequestCancels = true;
                notices = false;
              };
              ShowHiddenChannels = {
                enabled = true;
                showMode = 0;
                hideUnreads = true;
                defaultAllowedUsersAndRolesDropdownState = true;
              };
              ShowMeYourName = {
                enabled = true;
                mode = "nick-user";
                displayNames = false;
                inReplies = true;
              };
              SilentMessageToggle = {
                enabled = true;
                persistState = false;
                autoDisable = true;
              };
              Translate = {
                enabled = true;
                autoTranslate = false;
                receivedInput = "auto";
                receivedOutput = "en";
                showChatBarButton = true;
                sentInput = "auto";
                sentOutput = "en";
              };
              TypingTweaks = {
                enabled = true;
                alternativeFormatting = true;
                showRoleColors = true;
                showAvatars = true;
              };
              UserVoiceShow = {
                enabled = true;
                showVoiceChannelSectionHeader = true;
                showInUserProfileModal = true;
                showInMemberList = true;
                showInMessages = true;
              };
              ViewIcons = {
                enabled = true;
                format = "webp";
                imgSize = 1024;
              };
              ViewRaw = {
                enabled = true;
                clickMethod = "Left";
              };
              WebContextMenus = {
                enabled = true;
                addBack = true;
              };
              ShowHiddenThings = {
                enabled = true;
                showTimeouts = true;
                showInvitesPaused = true;
                showModView = true;
                disableDiscoveryFilters = true;
                disableDisallowedDiscoveryFilters = true;
              };
              MentionAvatars = {
                enabled = true;
                showAtSymbol = true;
              };
            };
          };
        };
      };
    };
  };
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FPV Last Run'**
  String get appTitle;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @levelSelect.
  ///
  /// In en, this message translates to:
  /// **'Level Select'**
  String get levelSelect;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main Menu'**
  String get mainMenu;

  /// No description provided for @legalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocuments;

  /// No description provided for @gamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Game screen placeholder'**
  String get gamePlaceholder;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FPV mission arcade'**
  String get splashSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get mission;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @lives.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get lives;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @playerLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get playerLevel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @russianLanguage.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russianLanguage;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @sfx.
  ///
  /// In en, this message translates to:
  /// **'SFX'**
  String get sfx;

  /// No description provided for @masterSound.
  ///
  /// In en, this message translates to:
  /// **'Master Sound'**
  String get masterSound;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @personalDataConsent.
  ///
  /// In en, this message translates to:
  /// **'Personal Data Consent'**
  String get personalDataConsent;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @termsAccepted.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use'**
  String get termsAccepted;

  /// No description provided for @personalDataAccepted.
  ///
  /// In en, this message translates to:
  /// **'I accept personal data processing'**
  String get personalDataAccepted;

  /// No description provided for @age13.
  ///
  /// In en, this message translates to:
  /// **'I am at least 13 years old'**
  String get age13;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get logoutSuccess;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'All server data and local tokens will be deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deleteAccountSuccess;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete'**
  String get confirmDelete;

  /// No description provided for @changeDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Change display name'**
  String get changeDisplayName;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @displayNameChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Display name updated'**
  String get displayNameChangeSuccess;

  /// No description provided for @invalidDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Use 3-20 letters, digits, or underscore.'**
  String get invalidDisplayName;

  /// No description provided for @nameChangedOnce.
  ///
  /// In en, this message translates to:
  /// **'Free name change'**
  String get nameChangedOnce;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score'**
  String get totalScore;

  /// No description provided for @completedMissions.
  ///
  /// In en, this message translates to:
  /// **'Completed missions'**
  String get completedMissions;

  /// No description provided for @unlockedMission.
  ///
  /// In en, this message translates to:
  /// **'Unlocked mission'**
  String get unlockedMission;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get bestScore;

  /// No description provided for @missionComplete.
  ///
  /// In en, this message translates to:
  /// **'Mission complete'**
  String get missionComplete;

  /// No description provided for @nextMission.
  ///
  /// In en, this message translates to:
  /// **'Next mission'**
  String get nextMission;

  /// No description provided for @baseScore.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get baseScore;

  /// No description provided for @flightAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Flight accuracy'**
  String get flightAccuracy;

  /// No description provided for @tankHit.
  ///
  /// In en, this message translates to:
  /// **'Tank hit'**
  String get tankHit;

  /// No description provided for @batteryBonus.
  ///
  /// In en, this message translates to:
  /// **'Battery bonus'**
  String get batteryBonus;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @backendSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Saved to profile'**
  String get backendSubmitted;

  /// No description provided for @guestResult.
  ///
  /// In en, this message translates to:
  /// **'Guest result'**
  String get guestResult;

  /// No description provided for @registrationRequiredAfterMission.
  ///
  /// In en, this message translates to:
  /// **'Register to continue to mission 3.'**
  String get registrationRequiredAfterMission;

  /// No description provided for @noLives.
  ///
  /// In en, this message translates to:
  /// **'No lives'**
  String get noLives;

  /// No description provided for @nextLifeIn.
  ///
  /// In en, this message translates to:
  /// **'Next life in'**
  String get nextLifeIn;

  /// No description provided for @remainingLives.
  ///
  /// In en, this message translates to:
  /// **'Remaining lives'**
  String get remainingLives;

  /// No description provided for @aboutFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'about 90 seconds'**
  String get aboutFiveMinutes;

  /// No description provided for @finalZone.
  ///
  /// In en, this message translates to:
  /// **'Final zone'**
  String get finalZone;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @simulateMissionComplete.
  ///
  /// In en, this message translates to:
  /// **'Simulate Mission Complete'**
  String get simulateMissionComplete;

  /// No description provided for @submittedScore.
  ///
  /// In en, this message translates to:
  /// **'Submitted score'**
  String get submittedScore;

  /// No description provided for @savedBestScore.
  ///
  /// In en, this message translates to:
  /// **'Saved best score'**
  String get savedBestScore;

  /// No description provided for @scoreImproved.
  ///
  /// In en, this message translates to:
  /// **'Score improved'**
  String get scoreImproved;

  /// No description provided for @scoreNotImproved.
  ///
  /// In en, this message translates to:
  /// **'Score not improved'**
  String get scoreNotImproved;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @yourPlace.
  ///
  /// In en, this message translates to:
  /// **'Your place'**
  String get yourPlace;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @totalPlayers.
  ///
  /// In en, this message translates to:
  /// **'Total players'**
  String get totalPlayers;

  /// No description provided for @emailStatus.
  ///
  /// In en, this message translates to:
  /// **'Email status'**
  String get emailStatus;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerified;

  /// No description provided for @confirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get confirmEmail;

  /// No description provided for @emailConfirmationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Email confirmation coming soon'**
  String get emailConfirmationComingSoon;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @regularAccount.
  ///
  /// In en, this message translates to:
  /// **'Regular account'**
  String get regularAccount;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get guestMode;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @registrationRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration required'**
  String get registrationRequired;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter email and password.'**
  String get invalidEmailOrPassword;

  /// No description provided for @passwordResetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset coming soon'**
  String get passwordResetComingSoon;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms of use.'**
  String get acceptTermsRequired;

  /// No description provided for @acceptPersonalDataRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept personal data consent.'**
  String get acceptPersonalDataRequired;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm that you are at least 13 years old.'**
  String get ageRequired;

  /// No description provided for @completePreviousMission.
  ///
  /// In en, this message translates to:
  /// **'Complete the previous mission first.'**
  String get completePreviousMission;

  /// No description provided for @loginRequiredToViewLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Login required to view leaderboard'**
  String get loginRequiredToViewLeaderboard;

  /// No description provided for @guestMissionCompletePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Guest mission complete placeholder'**
  String get guestMissionCompletePlaceholder;

  /// No description provided for @flightAccuracyBonus.
  ///
  /// In en, this message translates to:
  /// **'Flight accuracy bonus'**
  String get flightAccuracyBonus;

  /// No description provided for @tankHitBonus.
  ///
  /// In en, this message translates to:
  /// **'Tank hit bonus'**
  String get tankHitBonus;

  /// No description provided for @missionResult.
  ///
  /// In en, this message translates to:
  /// **'Mission result'**
  String get missionResult;

  /// No description provided for @goToLevels.
  ///
  /// In en, this message translates to:
  /// **'Go to levels'**
  String get goToLevels;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @backToMenu.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToMenu;

  /// No description provided for @backToLevels.
  ///
  /// In en, this message translates to:
  /// **'Back to levels'**
  String get backToLevels;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @restartMission.
  ///
  /// In en, this message translates to:
  /// **'Restart mission'**
  String get restartMission;

  /// No description provided for @missionFailed.
  ///
  /// In en, this message translates to:
  /// **'Mission failed'**
  String get missionFailed;

  /// No description provided for @droneDestroyed.
  ///
  /// In en, this message translates to:
  /// **'Drone destroyed'**
  String get droneDestroyed;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get tapToStart;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOver;

  /// No description provided for @drones.
  ///
  /// In en, this message translates to:
  /// **'Drones'**
  String get drones;

  /// No description provided for @flightTrails.
  ///
  /// In en, this message translates to:
  /// **'Flight Trails'**
  String get flightTrails;

  /// No description provided for @nicknameChange.
  ///
  /// In en, this message translates to:
  /// **'Nickname change'**
  String get nicknameChange;

  /// No description provided for @deleteAccountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Account deletion will be connected to the API later'**
  String get deleteAccountPlaceholder;

  /// No description provided for @exitGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit game?'**
  String get exitGameTitle;

  /// No description provided for @exitGameMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will be closed.'**
  String get exitGameMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitConfirm;

  /// No description provided for @exitUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exit is not implemented on this platform'**
  String get exitUnavailable;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked'**
  String get achievementUnlocked;

  /// No description provided for @achievementFirstRunTitle.
  ///
  /// In en, this message translates to:
  /// **'First Run'**
  String get achievementFirstRunTitle;

  /// No description provided for @achievementFirstRunDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete mission 1.'**
  String get achievementFirstRunDescription;

  /// No description provided for @achievementTrainingCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Complete'**
  String get achievementTrainingCompleteTitle;

  /// No description provided for @achievementTrainingCompleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete missions 1 and 2.'**
  String get achievementTrainingCompleteDescription;

  /// No description provided for @achievementFifthTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Fifth Target'**
  String get achievementFifthTargetTitle;

  /// No description provided for @achievementFifthTargetDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock mission 5.'**
  String get achievementFifthTargetDescription;

  /// No description provided for @achievementMvpCampaignTitle.
  ///
  /// In en, this message translates to:
  /// **'MVP Campaign'**
  String get achievementMvpCampaignTitle;

  /// No description provided for @achievementMvpCampaignDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 missions.'**
  String get achievementMvpCampaignDescription;

  /// No description provided for @achievementCleanHitTitle.
  ///
  /// In en, this message translates to:
  /// **'Clean Hit'**
  String get achievementCleanHitTitle;

  /// No description provided for @achievementCleanHitDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn a high tank hit bonus.'**
  String get achievementCleanHitDescription;

  /// No description provided for @achievementBullseyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bullseye'**
  String get achievementBullseyeTitle;

  /// No description provided for @achievementBullseyeDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn a perfect tank hit bonus.'**
  String get achievementBullseyeDescription;

  /// No description provided for @achievementStableFlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Stable Flight'**
  String get achievementStableFlightTitle;

  /// No description provided for @achievementStableFlightDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn a high flight accuracy bonus.'**
  String get achievementStableFlightDescription;

  /// No description provided for @achievementPerfectScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score'**
  String get achievementPerfectScoreTitle;

  /// No description provided for @achievementPerfectScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn the maximum mission score.'**
  String get achievementPerfectScoreDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

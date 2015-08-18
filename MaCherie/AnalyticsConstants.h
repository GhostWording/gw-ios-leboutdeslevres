//
//  AnalyticsConstants.h
//  MaCherie
//
//  Created by Mathieu Skulason on 30/05/15.
//  Copyright (c) 2015 Mathieu Skulason. All rights reserved.
//

#ifndef MaCherie_AnalyticsConstants_h
#define MaCherie_AnalyticsConstants_h

// GOOGLE ANALYTICS SCREENS //

#define GA_SCREEN_MAIN @"MainScreen"
#define GA_SCREEN_SETTINGS @"SettingsScreen"
#define GA_SCREEN_LOGIN @"LoginScreen"
#define GA_SCREEN_SPECIAL_OCCASION @"SpecialOccasion"

// GOOGLE ANALYTICS CATEGORIES //

#define GA_CATEGORY_USER_INFORMATION @"UserInformation"
#define GA_CATEGORY_TEXT_EDIT @"EditedTextIdSent"
#define GA_CATEGORY_TEXT_CREATED @"CreatedText"
#define GA_CATEGORY_IMAGE_EDIT @"EditedImageIdSent"
#define GA_CATEGORY_TEXT_SENT @"TextIdSent"
#define GA_CATEGORY_IMAGE_SENT @"ImageIdSent"
#define GA_CATEGORY_IMAGE_ONLY_SENT @"ImageOnlyIdSent"
#define GA_CATEGORY_TEXT_SHARE @"TextIdFacebookShare"
#define GA_CATEGORY_IMAGE_SHARE @"ImageIdFacebookShare"
#define GA_CATEGORY_IMAGE_INTERACTION @"ImageInteraction"
#define GA_CATEGORY_TEXT_INTERACTION @"TextInteraction"
#define GA_CATEGORY_APP_EVENT @"AppEvent"
#define GA_CATEGORY_SPECIAL_INTENTION @"SpecialIntention"
#define GA_CATEGORY_LOGIN @"Login"

// GOOGLE ANALYTCS ACTIONS //

#define GA_ACTION_BUTTON_PRESSED @"ButtonPressed"
#define GA_ACTiON_PICKER_SELECTION @"PickerSelection"
#define GA_ACTION_SWITCH_PRESSED @"SwitchPressed"
#define GA_ACTION_SCROLLING @"ScrollAction"
#define GA_ACTION_CELL_SELECTION @"CellSelection"

// GOOGLE ANALYTICS LABELS //

#define GA_LABEL_GENDER_MALE @"UserIsMale"
#define GA_LABEL_GENDER_FEMALE @"UserIsFemale"

#define GA_LABEL_AGE_LESS_18 @"LessThan18"
#define GA_LABEL_AGE_BETWEEN_18_40 @"18-39"
#define GA_LABEL_AGE_BETWEEN_40_64 @"40-64"
#define GA_LABEL_AGE_OVER_65 @"65AndOver"

#define GA_LABEL_USER_WANTS_NOTIFICATION @"UserWantsNotification"
#define GA_LABEL_USER_NOTIFICATION_TIME @"UserNotificationTime"

#define GA_LABEL_IMAGE_SWIPE @"ImageSwipe"
#define GA_LABEL_TEXT_SWIPE @"TextSwipe"

#endif

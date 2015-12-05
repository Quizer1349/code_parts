///////////////////////////////////////////
// Common data sources and classes
///////////////////////////////////////////
#import "Macros.h"
#import "PGViewController.h"
#import "LanguageManager.h"
#import <AWSCore/AWSCore.h>
#import "PGFreeDownloadManager.h"


///////////////////////////////////////////
// Google Analitics
///////////////////////////////////////////
#define GOOGLE_TRACKING_ID @"UA-60490819-1"

///////////////////////////////////////////
// Some data
///////////////////////////////////////////
#define RETINA4_PREFIX @"-568"

///////////////////////////////////////////
// IAP product ID
///////////////////////////////////////////
static NSString *const const_iap_productId = @"com.posingguide.fullcontent";
static NSString *const const_iap_statusKey = @"isPurchased";
static NSString *const const_iap_freeDownloaded = @"isFreeDownloaded";


///////////////////////////////////////////
// Cloud settings
///////////////////////////////////////////

static AWSRegionType const CognitoRegionType = AWSRegionEUWest1; // e.g. AWSRegionUSEast1
static AWSRegionType const DefaultServiceRegionType = AWSRegionEUWest1; // e.g. AWSRegionUSEast1
static NSString *const CognitoIdentityPoolId = @"eu-west-1:57b0468a-b420-40d5-a46e-74f29c8c7ea4";
static NSString *const S3BucketNameFree = @"com.posingguide.free";
static NSString *const S3BucketNamePay = @"com.posingguide.pay";


///////////////////////////////////////////
// Language Manager
///////////////////////////////////////////
// NSUserDefaults keys
#define DEFAULTS_KEY_LANGUAGE_CODE @"LanguageCode" // The key against which to store the selected language code.
#define CURRENT_KEY_LANGUAGE_CODE @"PGCurrentLanguageCode" 
/*
 * Custom localised string macro, functioning in a similar way to the standard NSLocalizedString().
 */
#define LocalizedString(key, comment) \
[[LanguageManager sharedLanguageManager] getTranslationForKey:key]

///////////////////////////////////////////
// Rate App Helper
///////////////////////////////////////////
#define kTimesOfAppRunUntilShowAgain 8
#define kTimesOfAppRunShowAgainIfCancelled 17

///////////////////////////////////////////
// Ads
///////////////////////////////////////////

#define const_ads_controllerAndCountToShow  @{@"PGMainViewController": @"2", @"PGFavoritesViewController": @"1", @"PGRulesViewController": @"1", @"PGPhotoViewerViewController": @"1"}


///////////////////////////////////////////
// App settings
///////////////////////////////////////////

#define kAppStoreAddress @"itms-apps://itunes.apple.com/app/id979139102"
#define kAppName @"PoseGuide"

#define kAppPortalAddressVideo @"https://www.youtube.com/watch?v=3yYiTQ3cKx4"
#define kFeedbackEmail @"poseguide@gmail.com"

///////////////////////////////////////////
// Parse.com
///////////////////////////////////////////

#define PARSE_APP_ID @"AfIXqFFpuPtYsGgSPZrUc3OgpewihxbKSVffnh4S"
#define PARSE_CLIENT_KEY @"RnARCD5Ny0QF6hm5GV3ErwEp3NsUwIkND28daAss"

///////////////////////////////////////////
// Menu items
///////////////////////////////////////////
#define CIRCLE_MENU_LABEL_ITEMS @[@"FAVORITES", @"RULES", @"FULL VERSION", @"MORE..."]
#define CIRCLE_MENU_LABEL_ITEMS_FULL @[@"FAVORITES", @"RULES", @"RESTORE", @"MORE..."]
#define CIRCLE_POSE_MENU_LABEL_ITEMS @[@"saveCM", @"favorites", @"tips", @"photo"]

///////////////////////////////////////////
// Social sharing API keys
///////////////////////////////////////////
static NSString *const const_apiKey_Facebook    = @"1415413108760078";
static NSString *const const_apiKey_Vkontakte   = @"4816511";
static NSString *const const_apiKey_Twitter     = @"";


///////////////////////////////////////////
// Pose photo count
///////////////////////////////////////////
#define PORTRAIT_PHOTO_COUNT @"103"
#define STANDING_PHOTO_COUNT @"215"
#define KNEELING_PHOTO_COUNT @"64"
#define SITTING_PHOTO_COUNT  @"172"
#define LAYING_PHOTO_COUNT   @"143"
#define MOTION_PHOTO_COUNT   @"31"

#define POSE_BUTTONS_ORDER @[PORTRAIT_PHOTO_COUNT, STANDING_PHOTO_COUNT, KNEELING_PHOTO_COUNT, SITTING_PHOTO_COUNT, LAYING_PHOTO_COUNT, MOTION_PHOTO_COUNT]

///////////////////////////////////////////
// File names
///////////////////////////////////////////
static NSString *const const_fileName_iphoneStoryboard = @"Main_iPhone";
static NSString *const const_fileName_ipadStoryboard   = @"Main_iPad";

static NSString *const const_fileName_mainBG           = @"bg";
static NSString *const const_fileName_navBarBG         = @"bg-header";
static NSString *const const_fileName_headerLogo       = @"logo-header";
static NSString *const const_fileName_headerLogoEn     = @"logo-header_en";

static NSString *const const_fileName_navBarBack       = @"header-arrow-back";
static NSString *const const_fileName_navBarBackHover  = @"header-arrow-back-hover";
static NSString *const const_fileName_navBarHome       = @"header-home";
static NSString *const const_fileName_navBarHomeHover  = @"header-home-hover";

static NSString *const const_fileName_mainScreenShadow = @"bg-shadow-home";

static NSString *const const_fileName_poseMenuStanding = @"item-menu-standing";
static NSString *const const_fileName_poseMenuSitting  = @"item-menu-sitting";
static NSString *const const_fileName_poseMenuLying    = @"item-menu-lying";
static NSString *const const_fileName_poseMenuOnKnees  = @"item-menu-on-his-knees";
static NSString *const const_fileName_poseMenuPortrait = @"item-menu-portrait";
static NSString *const const_fileName_poseMenuMoving   = @"item-menu-moving";

static NSString *const const_fileName_hoverImagePrefix   = @"hover";


static NSString *const const_fileName_ruleIncorrectIcon = @"icon-rule-false";
static NSString *const const_fileName_ruleCorrectIcon   = @"icon-rule-true";

static NSString *const const_fileName_needPurchaseIcon  = @"purchase-the-full-version";

static NSString *const const_fileName_watermarkImage    = @"watermark";

static NSString *const const_fileName_fullVerBgHor    = @"fullver_bg_hor";
static NSString *const const_fileName_fullVerBgVert    = @"fullver_bg_vert";


//CONTENT BUNDLES
static NSString *const const_fileName_freeContentBundleName = @"free_content";
static NSString *const const_fileName_payContentBundleName  = @"pay_content";

//Screen Titles
static NSString *const const_title_favorites = @"favorites";
static NSString *const const_title_buy       = @"buy";
static NSString *const const_title_more      = @"more";
static NSString *const const_title_changeLang = @"change language";

///////////////////////////////////////////
// Segues IDs
///////////////////////////////////////////
static NSString *const const_segueId_RulesToOneRule     = @"RulesToRuleSegue";
static NSString *const const_segueId_MainToSubPose      = @"MainToSubPose";
static NSString *const const_segueId_MainToPoseMenu     = @"MainToPoseMenu";
static NSString *const const_segueId_subPoseToPoseMenu  = @"subPoseToPoseMenu";
static NSString *const const_segueId_PoseMenuToCamera   = @"PoseMenuToCamera";
static NSString *const const_segueId_favsToPoseMenu     = @"favsToPoseMenu";
static NSString *const const_segueId_mainToFullVerSegue = @"MainToFullVerSegue";
static NSString *const const_segueId_mainToInstruction  = @"mainToInstruction";

///////////////////////////////////////////
// Cells IDs
///////////////////////////////////////////
static NSString *const const_cellId_fullVerListCell = @"fullVerListCell";
static NSString *const const_cellId_fullVerListCellIpad = @"fullVerListCellIpad";
static NSString *const const_cellId_langCell = @"langCell";
static NSString *const const_cellId_langCellIpad = @"langCellIpad";

///////////////////////////////////////////
// Core Data
///////////////////////////////////////////
static NSString *const const_coreData_rulesEntity = @"Rule";
static NSString *const const_coreData_posesEntity = @"Pose";
static NSString *const const_coreData_favsEntity  = @"Favorites";

///////////////////////////////////////////
// Poses
///////////////////////////////////////////
static NSString *const const_pose_standing = @"standing";
static NSString *const const_pose_sitting  = @"sitting";
static NSString *const const_pose_lying    = @"lying";
static NSString *const const_pose_knees    = @"knees";
static NSString *const const_pose_portrait = @"portrait";
static NSString *const const_pose_moving   = @"moving";

///////////////////////////////////////////
// Localizable strings
///////////////////////////////////////////

/*Instructions steps titles and texts*/
static NSString *const const_local_instructionTitle_Step_0    = @"ls_instructionTitle_Step_0";
static NSString *const const_local_instructionTitle_Step_1    = @"ls_instructionTitle_Step_1";
static NSString *const const_local_instructionTitle_Step_2    = @"ls_instructionTitle_Step_2";
static NSString *const const_local_instructionTitle_Step_3    = @"ls_instructionTitle_Step_3";
static NSString *const const_local_instructionTitle_Step_4    = @"ls_instructionTitle_Step_4";
static NSString *const const_local_instructionTitle_Step_5    = @"ls_instructionTitle_Step_5";

static NSString *const const_local_instructionText_Step_0    = @"ls_instructionText_Step_0";
static NSString *const const_local_instructionText_Step_1    = @"ls_instructionText_Step_1";
static NSString *const const_local_instructionText_Step_2    = @"ls_instructionText_Step_2";
static NSString *const const_local_instructionText_Step_3    = @"ls_instructionText_Step_3";
static NSString *const const_local_instructionText_Step_4    = @"ls_instructionText_Step_4";
static NSString *const const_local_instructionText_Step_5    = @"ls_instructionText_Step_5";

#define INSTRUCTION_STEPS_TITLES_ARRAY @[const_local_instructionTitle_Step_0, const_local_instructionTitle_Step_1, const_local_instructionTitle_Step_2, const_local_instructionTitle_Step_3, const_local_instructionTitle_Step_4, const_local_instructionTitle_Step_5]

#define INSTRUCTION_STEPS_TEXTS_ARRAY @[const_local_instructionText_Step_0, const_local_instructionText_Step_1, const_local_instructionText_Step_2, const_local_instructionText_Step_3, const_local_instructionText_Step_4, const_local_instructionText_Step_5]


/*Rate App alert*/
static NSString *const const_local_rateAppAlertMessage       = @"ls_rateAppAlertMessage";
static NSString *const const_local_rateAppNeverAskAgain      = @"ls_rateAppNeverAskAgain";
static NSString *const const_local_rateAppAlertRateItNow     = @"ls_rateAppAlertRateItNow";
static NSString *const const_local_rateAppAlertRemindMeLater = @"ls_ateAppAlertRemindMeLater";


/*Full version titles*/
static NSString *const const_local_fullVerTitleContaines   = @"ls_fullVerTitleContaines";
static NSString *const const_local_fullVerTitleInstalled   = @"fullVerTitleInstalled";


/*Full version items*/
static NSString *const const_local_fullVerItemSubparts = @"ls_fullVerItemSubparts";
static NSString *const const_local_fullVerItemModels   = @"ls_fullVerItemModels";
static NSString *const const_local_fullVerItemDresses  = @"ls_fullVerItemDresses";
static NSString *const const_local_fullVerItemPoses    = @"ls_fullVerItemPoses";
static NSString *const const_local_fullVerItemPlaces   = @"ls_fullVerItemPlaces";
static NSString *const const_local_fullVerItemTips     = @"ls_fullVerItemTips";
static NSString *const const_local_fullVerItemOutlines     = @"ls_fullVerItemOutlines";

/*Feedback email*/
static NSString *const const_local_feedbackEmailSubject    = @"ls_feedbackEmailSubject";
static NSString *const const_local_feedbackEmailBody       = @"ls_feedbackEmailBody";

static NSString *const const_local_feedbackEmailErrorAlertTitle = @"ls_feedbackEmailErrorAlertTitle";
static NSString *const const_local_feedbackEmailErrorAlertMsg   = @"ls_feedbackEmailErrorAlertMsg";

/*Rules screen*/
static NSString *const const_local_ruleNumberTitle = @"ls_ruleNumberTitle";

/*Share Menu*/
static NSString *const const_local_shareMenuLabel = @"ls_shareMenuLabel";

/*Share Alerts and some Settings*/
static NSString *const const_local_shareInstaAlertMsg     = @"ls_shareInstaAlertMsg";
static NSString *const const_local_shareInstaAlertTitle   = @"ls_shareInstaAlertTitle";
static NSString *const const_local_shareDefaultText       = @"ls_shareDefaultText";
static NSString *const const_local_shareMailDefaultText   = @"ls_shareMailDefaultText";

/*Change language alert*/
static NSString *const const_local_langChangedAlertMsg     = @"ls_langChangedAlertMsg";
static NSString *const const_local_langChangedAlertTitle   = @"ls_langChangedAlertTitle";
static NSString *const const_local_langChangedCloseAppBtn  = @"ls_langChangedCloseAppBtn";

/*Not allowed camera alert*/
static NSString *const const_local_notAllowedCamAlertMsg     = @"ls_notAllowedCamAlertMsg";
static NSString *const const_local_notAllowedCamAlertTitle   = @"ls_notAllowedCamAlertTitle";
static NSString *const const_local_notAllowedCamCloseAppBtn  = @"ls_notAllowedCamCloseAppBtn";


/*Content downloading alerts*/
static NSString *const const_local_itunesConnectError = @"ls_itunesConnectError";
static NSString *const const_local_tryLaterError      = @"ls_tryLaterError";
static NSString *const const_local_downloadError      = @"ls_downloadError";











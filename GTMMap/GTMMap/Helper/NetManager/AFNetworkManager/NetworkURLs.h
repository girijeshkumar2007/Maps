//
//  NetworkURLs.h
//
//  Created by Girijesh  on 18/12/14.
//  Copyright (c) 2014 Girijesh . All rights reserved.
//

#ifndef TechaHeadBase_NetworkURLs_h
#define TechaHeadBase_NetworkURLs_h

#import "DDLog.h"


// HTTP Basic Authentication
#define kHTTPUsername	 @""
#define kHTTPPassword	 @""
#define kDeviceType @"1" //1-iOS 2- Andoid


#define OS                          [[UIDevice currentDevice] systemVersion]
#define kAppVersion                 @"1.0"
#define kDeviceModel                [[UIDevice currentDevice] model]
#define kDeviceType                 @"1"
#define kAPIKEY                     @"cesar@123"

/** --------------------------------------------------------
 *		Techahead API Base URL defined by Targets.
 *	--------------------------------------------------------
 */


// GTM Server
#define kBASEURL     @"http://www.dharmamaps.com/newpanel/map/rest/"
#define kImageBaseUrl @"http://www.dharmamaps.com"

#if DEBUG
static int ddLogLevel = LOG_LEVEL_VERBOSE;
#elif TEST
static int ddLogLevel = LOG_LEVEL_INFO;
#elif STAGE
static int ddLogLevel = LOG_LEVEL_WARN;
#else
static int ddLogLevel = LOG_LEVEL_ERROR;
#endif

/** --------------------------------------------------------
 *		Customize NSLog in Debug mode
 *  --------------------------------------------------------
 */
#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)


/*****************************************************************************/
/* Entry/exit trace macros                                                   */
/*****************************************************************************/
#define TRC_ENTRY()    DDLogVerbose(@"ENTRY: %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#define TRC_EXIT()     DDLogVerbose(@"EXIT:  %s:%d:", __PRETTY_FUNCTION__,__LINE__);




/** -------------------------------- ------------------------
 *		Common Request Param
 *	--------------------------------------------------------
 */

#define kuserPlaceholder                            @"default_pic"


/** --------------------------------------------------------
 *		CoreData Table Name
 *	--------------------------------------------------------
 */

#define kTableClass                                 @"Classes"


/** --------------------------------------------------------
 *		Common Response Param
 *	--------------------------------------------------------
 */
#define KParamKeyLoading              @"Loading..."
#define kParamKeySuccess              @"Success"
#define kParamKeyMessage              @"Message"
#define kParamKeyResult               @"Result"
#define kParamKeyStatus               @"Status"

#define kAllMaps                      @"allmaps.php"

#endif





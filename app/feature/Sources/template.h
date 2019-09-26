#ifndef SCAppConfigForRemainButler_h
#define SCAppConfigForRemainButler_h

{% if app.debug %}
#ifdef DEBUG
static NSString * const kDistributioneBaseCommonUrl         = @"{{ info.debug.kkDistributioneBaseCommonUrl }}"
static NSString * const kJPushAppKeyString                  = @"317f4903eb31beeb1d251838";
static NSString * const kJPushChannelID                     = @"开发";
static NSString * const kUMengAppKeyString                  = @"5c9db02961f564071a000267";
static NSString * const kUMengChannelID                     = @"开发";
static NSString * const kWechatAppId                        = @"wx8ca3d6d968df7b69";
static NSString * const kWechatAppKey                       = @"a671f35a97d1bc85ed897fd4aa4d71ad";
static NSString * const kTencentQQAppId                     = @"1108368982";
static NSString * const kTencentQQAppKey                    = @"bTMMW1E6XqrPkFGx";
static NSString * const kAPIVersion                         = @"2";
static NSString * const kAPISalt                            = @"v5TuKvrzQBZ6b3Qg9emq";
static NSString * const kMobiletype                         = @"153";
static NSString * const kCompanyCode                        = @"mh";
static NSString * const kVersionCheckType                   = @"ios-wuguan-mh";
static NSString * const kIDCardScanDevcode                  = @"5P2T5BEE57UA5RY";
static NSString * const kPlateNumberScanDevcode             = @"5P2T5BEE57UA5RY";
#endif
{% endif %}

#endif /* SCAppConfigForRemainButler_h */

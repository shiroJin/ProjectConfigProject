module ButlerHeaderFile
  # butler args list
  def ButlerHeaderFile.keys
    return [
      "kDistributioneBaseCommonUrl",
      "kJPushAppKeyString",
      "kJPushChannelID",
      "kUMengAppKeyString",
      "kUMengChannelID",
      "kWechatAppId",
      "kWechatAppKey",
      "kTencentQQAppId",
      "kTencentQQAppKey",
      "AESSecretKey",
      "AESSecretVI",
      "kPaykey",
      "kIV",
      "kAPIVersion",
      "kAPISalt",
      "kMobiletype",
      "kCompanyCode",
      "kVersionCheckType",
      "kIDCardScanDevcode",
      "kPlateNumberScanDevcode"    
    ]
  end

  # parse header file
  def ButlerHeaderFile.parse_headerfile(file_path)
    hash = Hash.new
    unless File.readable?(file_path)
      return hash
    end 
    IO.foreach(file_path) { |line|
      data = []
      if line.index('#define')
        data = line.gsub(/(#define|\s|"|\n)/, '').split('@')
      elsif line.index('static')
        data = line.gsub(/\s/, '').gsub(/(staticNSString\*(const)?|@"|"|;|\n)/, '').split('=')
      end
      
      if data.length == 2
        hash[data[0]] = data[1]
      end
    }
    return hash
  end

  def ButlerHeaderFile.write_to_file(hash, dest)
    content = %Q{
#ifndef SCAppConfigForButler_h
#define SCAppConfigForButler_h
    \n}

    ButlerHeaderFile.keys.each do |key|
      if hash[key] == nil
        content += %Q{static NSString * const #{key} = "";\n}
        next
      end
      content += %Q{static NSString * const #{key} = @"#{hash[key]}";\n}
    end
        
    content += %q{
// URL的配置类型
typedef NS_ENUM(NSInteger, SCURLType) {
    /// 老环境
    SCURLTypeOld = 0,
    /// 新环境
    SCURLTypeNew = 1,
    /// H5
    SCURLTypeWeb = 2,
    /// 图片上传
    SCURLTypeUpload = 3,
    /// 长连接
    SCURLTypeSocket = 4,
    /// 更新地址
    SCURLTypeUpdate = 5,
};

// 正式环境
static inline NSDictionary *kDistributioneDict() {
    return @{@(SCURLTypeOld) : [kDistributioneBaseCommonUrl stringByAppendingString:@"old"],
              @(SCURLTypeNew) : [kDistributioneBaseCommonUrl stringByAppendingString:@"butler"],
              @(SCURLTypeWeb) : [kDistributioneBaseCommonUrl stringByAppendingString:@"h5/butler"],
              @(SCURLTypeUpload) : kDistributioneBaseCommonUrl,
              @(SCURLTypeSocket) : [kDistributioneBaseCommonUrl stringByAppendingString:@"socket"],
              @(SCURLTypeUpdate) : [kDistributioneBaseCommonUrl stringByAppendingString:@"app/mh/butler.html"],
              };
}

// 根据type获取对应的url
static inline NSString *kConfigBaseUrl(SCURLType type) {
    return [kDistributioneDict() objectForKey:@(type)];
}

#endif /* SCAppConfigForButler_h */
}

    # write to dest file
    File.open(dest, 'w') { |f|
      f.syswrite(content)
    }
  end

end
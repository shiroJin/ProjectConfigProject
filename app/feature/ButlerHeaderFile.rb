require 'Liquid'

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
  def ButlerHeaderFile.load(file_path)
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

  def ButlerHeaderFile.dump(hash, dest)
    File.open()
    Liquid::Template.parse()
    # write to dest file
    File.open(dest, 'w') { |f|
      f.syswrite(content)
    }
  end

end
#!/usr/bin/env ruby

#require 'rubygems'
require 'nokogiri'
#require 'open-uri'

### Generic XML Functions
##Get XML file
def dotnetconfig_getXml(filename)
  @doc = Nokogiri::XML(File.open(filename)) do |config|
    config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS  
  end
  @doc
end

##Get set content
def dotnetconfig_getElementContent(filename, xpathQuery)
  element = dotnetconfig_getFirstElement(filename, xpathQuery)
  if !element.nil?
    element.content
  else
    nil
  end
end

def dotnetconfig_setElementContent(filename, xpathQuery, value)
  element = dotnetconfig_getFirstElement(filename, xpathQuery)
  if !element.nil?
    element.content = value
  end
end

##Element fetching
def dotnetconfig_getElements(filename, xpathQuery)
  @doc = dotnetconfig_getXml(filename)
  elements = @doc.xpath(xpathQuery)   
  if !elements.empty?
    elements
  else
    nil
  end
end

def dotnetconfig_getFirstElement(filename, xpathQuery)
  @doc = dotnetconfig_getXml(filename)
  elements = @doc.xpath(xpathQuery)
  if !elements.empty?
    elements.first
  else
    nil
  end
end

##Attribute modification
def dotnetconfig_getByAttributeName(filename, xpathQuery, attributeName, attributeValue)
  @doc = dotnetconfig_getXml(filename)
  elements = dotnetconfig_getElements(filename, xpathQuery)
  attributes = elements.xpath(%Q'//*[@#{attributeName}="#{attributeValue}"]')
  if !attributes.empty?
    attributes.first
  else
    nil
  end
end

def dotnetconfig_setAttribute(filename, xpathQuery, attributeName, attributeValue, setAttributeName, setAttributeValue)
  attribute = dotnetconfig_getByAttributeName(filename, xpathQuery, attributeName, attributeValue)
  if !attribute.nil?
    attribute.set_attribute(setAttributeName, setAttributeValue)
  end
end

###DotNET Specific Configuration
##App Settings
def dotnetconfig_setAppSetting(filename, settingName, settingValue)
  dotnetconfig_setAttribute(filename, '//configuration/appSettings/add', 'key', settingName, 'value', settingValue)
end

def dotnetconfig_getAppSetting(filename, settingName)
  element = dotnetconfig_getByAttributeName(filename, '//configuration/appSettings/add', 'key', settingName)
  if !element.nil?
    #element.get_attribute('value')
    element['value']
  else
    nil
  end
end

##Full Connection Strings
def dotnetconfig_setConnectionString(filename, settingName, value)
  connectionString = dotnetconfig_getConnectionString(filename, settingName)
  if !connectionString.nil?
    dotnetconfig_setAttribute(filename, '//configuration/connectionStrings', 'name', settingName, 'connectionString', value)
  end
end

def dotnetconfig_getConnectionString(filename, settingName)
  connectionString = dotnetconfig_getByAttributeName(filename, '//configuration/connectionStrings', 'name', settingName)
  if !connectionString.nil?
    connectionString
  else
    connectionString
  end
end

##Hash list manipulation routines
def dotnetconfig_getConnectionStringHash(filename, connectionStringName)
  connectionString = dotnetconfig_getConnectionString(filename, connectionStringName)
  if !connectionString.nil?
    value = connectionString['connectionString']
    array = value.split(";")
    hash = nil;
    array.each { |x| 
      keypair = x.split("=")
      if hash.nil?
        hash = { keypair[0] => keypair[1] }
      else
        hash[keypair[0]] = keypair[1]
      end
    }
    hash
  end
end

def dotnetconfig_getConnectionStringFromHash(hashList)
  connectionString = ""
  hashList.each { |key, value|
    connectionString = connectionString + (key + "=" + value + ";")
  }
  connectionString
end

def dotnetconfig_getConnectionStringPart(hashList, key)
  if hashList.key?(key)
    hashList[key]
  end
end

def dotnetconfig_removeConnectionStringPart(hashList, key)
  if hashList.key?(key)
    hashList.delete(key)
  end
end

def dotnetconfig_setConnectionStringPart(hashList, key, value)
  if hashList.key?(key)
    hashList[key] = value
  end
end


###Implementation logic

#filename = "fixhyb.config.xml"

#hashList = dotnetconfig_getConnectionStringHash(filename, 'fix')
#part = dotnetconfig_getConnectionStringPart(hashList, 'user')
#dotnetconfig_setConnectionStringPart(hashList, 'user', 'none')
#dotnetconfig_removeConnectionStringPart(hashList, 'password')
#conn = dotnetconfig_getConnectionStringFromHash(hashList)

#print value
#print conn

#Setting an appSetting value
#value = dotnetconfig_getAppSetting(filename, 'fix-gateways')
#dotnetconfig_setAppSetting(filename, 'fix-gateways', value)

#Setting a connection string entirely
#conn = dotnetconfig_getConnectionStringHash(filename, 'fix', 'Database')
#dotnetconfig_setConnectionStringPart(conn, 'password', 'Thisiseventbetter')
#print dotnetconfig_getConnectionStringFromHash(conn)
#dotnetconfig_setConnectionString(filename, 'fix', 'ThisHasBeenReplaced')

#dotnetconfig_setElementContent(filename, '//configuration/messaging', '<messaging2>This has been replaced</messaging2>')

#dotnetconfig_getConnectionStringPart(filename, 'fix', 'Database')

#print conn

#Setting a part of the connection string

#element = dotnetconfig_getFirstElement(@filename, '//configuration/appSettings/add')
#elements = dotnetconfig_getElements(@filename, '//configuration/appSettings/add')

#print element
#print
#print elements
#print

#dotnetconfig_appSetting @filename, 'ClientSettingsProvider.ServiceUri', 'Edited'
#dotnetconfig_appSetting @filename, 'fix-gateways', 'Edit1'
#dotnetconfig_appSetting @filename, 'service-installer-service-name', 'Edit2'
#dotnetconfig_appSetting @filename, 'service-installer-service-description', 'Edit3'
#dotnetconfig_appSetting @filename, 'log-fixmessage-to-db', 'Edit4'
#dotnetconfig_appSetting @filename, 'default-version', 'Edit5'
#dotnetconfig_appSetting @filename, 'fix-service-test-file-name', 'Edit6'
#dotnetconfig_appSetting @filename, 'usetestconfig', 'Edit7'
#config_appSetting 'doesntexist', 'none'

#dotnetconfig_elementContent @filename, '//configuration/messaging/user', 'Edit8'
#dotnetconfig_elementContent @filename, '//configuration/messaging/password', 'Edit9'
#dotnetconfig_elementContent @filename, '//configuration/messaging/host', 'Edit10'
#dotnetconfig_elementContent @filename, '//configuration/messaging/port', 'Edit11'

#dotnetconfig_elementContent @filename, '//configuration/log4net/appender[@name="RabbitAppender"]/hostName', 'Wow'
#dotnetconfig_elementContent @filename, '//configuration/log4net/appender[@name="RabbitAppender"]/userName', 'Wow'
#dotnetconfig_elementContent @filename, '//configuration/log4net/appender[@name="RabbitAppender"]/password', 'Wow'

#config_connectionString @filename, 'fix', 'TotalReplacement'
#config_connectionString @filename, 'ems', 'Database=Partial;User Id=Replacement;Password=PasswordChanged;CommandTimeout=30;MinPoolSize=0'

#File.write('edit' + filename, @doc.to_xml)

#print @doc

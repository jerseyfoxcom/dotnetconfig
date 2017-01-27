#
# Author:: Adam ONeil
# Cookbook Name:: dotnetconfig
# Provider:: config
#
# Copyright:: 2010, Altis Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use_inline_resources
require 'nokogiri'

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

##Connection Strings
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

def dotnetconfig_getConnectionStringHash(filename, settingName, partName)
  connectionString = dotnetconfig_getConnectionString(filename, settingName)
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

def dotnetconfig_setConnectionStringPart(hashList, key, value)
  if hashList.key?(key)
    hashList[key] = value
  end
end

def dotnetconfig_getConnectionStringFromHash(hashList)
  connectionString = ""
  hashList.each { |key, value|
    connectionString = connectionString + (key + "=" + value + ";")
  }
  connectionString
end
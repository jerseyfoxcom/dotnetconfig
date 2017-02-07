#
# Author:: Adam ONeil (<adam@altispartners.com>)
# Cookbook Name:: dotnetconfig
# Library:: DotNetConfig
#
# Copyright:: 2017 Adam ONeil
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

require 'nokogiri'

module DotNetConfig
	### Generic XML Functions
	##Get XML file
	def config_getxml(filename)
	  @doc = Nokogiri::XML(File.open(filename)) do |config|
		config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS  
	  end
	  @doc
	end

	##Get set content
	def config_get_element_content(filename, xpathQuery)
	  element = dotnetconfig_get_first_element(filename, xpathQuery)
	  if !element.nil?
		element.content
	  else
		nil
	  end
	end

	def config_set_element_content(filename, xpathQuery, value)
	  element = dotnetconfig_get_first_element(filename, xpathQuery)
	  if !element.nil?
		element.content = value
	  end
	end

	##Element fetching
	def config_get_elements(filename, xpathQuery)
	  @doc = dotnetconfig_getxml(filename)
	  elements = @doc.xpath(xpathQuery)   
	  if !elements.empty?
		elements
	  else
		nil
	  end
	end

	def config_get_first_element(filename, xpathQuery)
	  @doc = dotnetconfig_getxml(filename)
	  elements = @doc.xpath(xpathQuery)
	  if !elements.empty?
		elements.first
	  else
		nil
	  end
	end

	##Attribute modification
	def config_get_by_attribute_name(filename, xpathQuery, attributeName, attributeValue)
	  @doc = dotnetconfig_getxml(filename)
	  elements = dotnetconfig_get_elements(filename, xpathQuery)
	  attributes = elements.xpath(%Q'//*[@#{attributeName}="#{attributeValue}"]')
	  if !attributes.empty?
		attributes.first
	  else
		nil
	  end
	end

	def config_set_attribute(filename, xpathQuery, attributeName, attributeValue, setAttributeName, setAttributeValue)
	  attribute = dotnetconfig_get_by_attribute_name(filename, xpathQuery, attributeName, attributeValue)
	  if !attribute.nil?
		attribute.set_attribute(setAttributeName, setAttributeValue)
	  end
	end

	###DotNET Specific Configuration
	##App Settings
	def config_set_app_setting(filename, settingName, settingValue)
	  dotnetconfig_set_attribute(filename, '//configuration/appSettings/add', 'key', settingName, 'value', settingValue)
	end

	def config_get_app_setting(filename, settingName)
	  element = dotnetconfig_get_by_attribute_name(filename, '//configuration/appSettings/add', 'key', settingName)
	  if !element.nil?
		#element.get_attribute('value')
		element['value']
	  else
		nil
	  end
	end

	##Full Connection Strings
	def config_set_connection_string(filename, settingName, value)
	  connectionString = dotnetconfig_get_connection_string(filename, settingName)
	  if !connectionString.nil?
		dotnetconfig_set_attribute(filename, '//configuration/connectionStrings', 'name', settingName, 'connectionString', value)
	  end
	end

	def config_get_connection_string(filename, settingName)
	  connectionString = dotnetconfig_get_by_attribute_name(filename, '//configuration/connectionStrings', 'name', settingName)
	  if !connectionString.nil?
		connectionString
	  else
		connectionString
	  end
	end

	##Hash list manipulation routines
	def config_get_connection_string_hash(filename, connectionStringName)
	  connectionString = dotnetconfig_get_connection_string(filename, connectionStringName)
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

	def config_get_connection_string_from_hash(hashList)
	  connectionString = ""
	  hashList.each { |key, value|
		connectionString = connectionString + (key + "=" + value + ";")
	  }
	  connectionString
	end

	def config_get_connection_string_part(hashList, key)
	  if hashList.key?(key)
		hashList[key]
	  end
	end

	def config_remove_connection_string_part(hashList, key)
	  if hashList.key?(key)
		hashList.delete(key)
	  end
	end

	def config_set_connection_string_part(hashList, key, value)
	  if hashList.key?(key)
		hashList[key] = value
	  end
	end
end

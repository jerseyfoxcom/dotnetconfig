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
	  doc = Nokogiri::XML(File.open(filename)) do |config|
		config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS  
	  end
	  doc
	end
	
	def config_writexml(document, filename)
	  File.write(filename, document.to_xml)
	end
	
	##Element fetching
	def config_get_elements(document, xpathQuery)
	  elements = document.xpath(xpathQuery)   
	  if !elements.empty?
		elements
	  else
		nil
	  end
	end

	def config_get_first_element(document, xpathQuery)
	  elements = document.xpath(xpathQuery)
	  if !elements.empty?
		elements.first
	  else
		nil
	  end
	end	

	##Get set content
	def config_get_element_content(document, xpathQuery)
	  element = config_get_first_element(document, xpathQuery)
	  if !element.nil?
		element.content
	  else
		nil
	  end
	end

	def config_set_element_content(document, xpathQuery, value)
	  element = config_get_first_element(document, xpathQuery)
	  if !element.nil?
		element.content = value
	  end
	end

	##Attribute modification
	def config_get_by_attribute_name(document, xpathQuery, attributeName, attributeValue)
	  elements = config_get_elements(document, xpathQuery)
	  attributes = elements.xpath(%Q'//*[@#{attributeName}="#{attributeValue}"]')
	  if !attributes.empty?
		attributes.first
	  else
		nil
	  end
	end

	def config_set_attribute(document, xpathQuery, attributeName, attributeValue, setAttributeName, setAttributeValue)
	  attribute = config_get_by_attribute_name(document, xpathQuery, attributeName, attributeValue)
	  if !attribute.nil?
		attribute.set_attribute(setAttributeName, setAttributeValue)
	  end
	end

	###DotNET Specific Configuration
	##App Settings
	def config_set_app_setting(document, settingName, settingValue)
	  config_set_attribute(document, '//configuration/appSettings/add', 'key', settingName, 'value', settingValue)
	end

	def config_get_app_setting(document, settingName)
	  element = config_get_by_attribute_name(document, '//configuration/appSettings/add', 'key', settingName)
	  if !element.nil?
		#element.get_attribute('value')
		element['value']
	  else
		nil
	  end
	end

	##Full Connection Strings
	def config_set_connection_string(document, settingName, value)
	  connectionString = config_get_connection_string(document, settingName)
	  if !connectionString.nil?
		config_set_attribute(document, '//configuration/connectionStrings', 'name', settingName, 'connectionString', value)
	  end
	end

	def config_get_connection_string(document, settingName)
	  connectionString = config_get_by_attribute_name(document, '//configuration/connectionStrings', 'name', settingName)
	  if !connectionString.nil?
		connectionString
	  else
		connectionString
	  end
	end

	##Connection String Properties
	def config_set_connection_string_property(document, connectionStringName, propertyName, propertyValue)
		hash = config_get_connection_string_hash(document, connectionStringName)
		hashList = config_set_connection_string_part(hash, propertyName, propertyValue)
		connectionString = config_get_connection_string_from_hash(hashList)
		config_set_connection_string(document, connectionStringName, connectionString)
	end
	
	##Hash list manipulation routines
	def config_get_connection_string_hash(document, connectionStringName)
	  connectionString = config_get_connection_string(document, connectionStringName)
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
	  hashList
	end

	def config_set_connection_string_part(hashList, key, value)
	  if hashList.key?(key)
		hashList[key] = value
	  end
	  hashList
	end
end

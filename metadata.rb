name             'dotnetconfig'
maintainer       'Adam ONeil'
maintainer_email 'adam@altispartners.com'
license          'All rights reserved'
description      'Installs/Configures dotnetconfig'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.3'

#Cookbook dependencies - Nokogiri
depends 	'nokogiri'

#Support Windows
supports	'windows'

# If you upload to Supermarket you should set this so your cookbook gets a `View Issues` link 
issues_url 'https://github.com/jerseyfoxcom/dotnetconfig/issues' if respond_to?(:issues_url) 
# If you # upload to Supermarket you should set this so your cookbook gets a `View Source` link
source_url 'https://github.com/jerseyfoxcom/dotnetconfig' if respond_to?(:source_url)

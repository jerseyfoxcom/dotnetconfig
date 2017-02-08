dotnetconfig Cookbook
=====================

##NET configuration file editor. Provides functionality to update a .NET app / web configuration file with values from a chef run.

WORK IN PROGRESS - Currently in Alpha, feel free to test it out but don't use in production until this message is removed or we have hit V1.0.0.

##Open the file for editing, non locking
```ruby
documentPath = 'C:\\Config\\' + 'app.config'
document = config_getxml(documentPath)
```

##Set app settings within the config file<
Arguments:
  Document: Pass document which was fetched from config_getxml
  SettingName: The setting to update
  SettingValue: The new value to apply to the configuration

```ruby
config_set_app_setting(document, 'fix-gateways', 'Replaced')
config_set_app_setting(document, 'service-installer-service-name', 'Edit2')
config_set_app_setting(document, 'service-installer-service-description', 'Edit3')
config_set_app_setting(document, 'log-fixmessage-to-db', 'Edit4')
config_set_app_setting(document, 'default-version', 'Edit5')
config_set_app_setting(document, 'fix-service-test-file-name', 'Edit6')
```

##Setting custom elements
Set an element's content using an xPath query, Example:

```xml
<custom>
  <user>AValue1</user>
  <password>AValue2</password>
  <host>AValue3</host>
  <port>AValue4</port>
</custom>
```

This block would find the first occurrence of the 'custom' element and set the content of each of its elements to a new value.

```ruby
config_set_element_content(document, '//configuration/custom/user', 'Edit8')
config_set_element_content(document, '//configuration/custom/password', 'Edit9')
config_set_element_content(document, '//configuration/custom/host', 'Edit10')
config_set_element_content(document, '//configuration/custom/port', 'Edit11')
```

##Setting the content of a specific element using xPath
This would find the first log4net appender called MyAppender

```ruby
config_set_element_content(document, '//configuration/log4net/appender[@name="MyAppender"]/hostName', 'NewValue1')
config_set_element_content(document, '//configuration/log4net/appender[@name="MyAppender"]/userName', 'NewValue2')
config_set_element_content(document, '//configuration/log4net/appender[@name="MyAppender"]/password', 'NewValue3')
```

##Connection strings

Set the the entire content of a connection string
```ruby
config_set_connection_string(document, 'Database1', 'Database=Partial;User Id=Replacement;Password=PasswordChanged;CommandTimeout=30;MinPoolSize=0')
```

Set an individual property within a connection string

```ruby
config_set_connection_string_property(document, 'Database2', 'password', 'NewValue123654')
```

Saving changes made to the file

```ruby
config_writexml(document, outputPath)
```

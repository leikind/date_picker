if defined?(DatePicker)
  
  DatePicker::DATE_FORMAT = "%d %B %Y"
  DatePicker::DATETIME_FORMAT = "%d %B %Y %H:%M"

  DatePicker::DATE_FORMAT_HIDDEN_FIELD = "%Y-%m-%d"
  DatePicker::DATETIME_FORMAT_HIDDEN_FIELD = "%Y-%m-%d %H:%M:00"
  
  DatePicker::EMBEDDED_CALENDAR = false
  DatePicker::HIDE_ON_CLICK_ON_DAY = false
  
  DatePicker::DATE_STRING_TOOLTIP = "Click to delete"
  DatePicker::ALLOW_ONLY_ONE_POPUP_CALENDAR = false
  DatePicker::MINUTE_STEP = 5
  
  DatePicker::DEFAULT_ON_CHANGED_JS_CALLBACK =%! calendar.viewOutputFields().each(function(f){new Effect.Highlight(f, {queue: 'end' })}) !
  DatePicker::DEFAULT_ON_HIDE_JS_CALLBACK = DatePicker::DEFAULT_ON_CHANGED_JS_CALLBACK
  
  DatePicker::LANGUAGE = 'en' # 'fr' or 'nl'
end
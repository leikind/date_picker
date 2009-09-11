if defined?(DatePicker)
  DatePicker::NIL_DATE_VIEW = ''
  DatePicker::NIL_DATE_PROMPT = ''
  # DatePicker::DATE_FORMAT = "%d-%B-%Y"
  # DatePicker::DATETIME_FORMAT = "%d-%B-%Y-%H:%M"
  
  DatePicker::DATE_FORMAT = "%d %B %Y"
  DatePicker::DATETIME_FORMAT = "%d %B %Y %H:%M"

  DatePicker::DATE_FORMAT_HIDDEN_FIELD = "%Y-%m-%d"
  DatePicker::DATETIME_FORMAT_HIDDEN_FIELD = "%Y-%m-%d %H:%M:00"
  
  
  DatePicker::DATE_STRING_TOOLTIP = "Click to delete"
  DatePicker::ALLOW_ONLY_ONE_POPUP_CALENDAR = false
  DatePicker::MINUTE_STEP = 5
  
  DatePicker::DEFAULT_ON_CHANGED_JS_CALLBACK =%!  new Effect.Highlight(calendar.dateField, {queue: 'end' })  !
  DatePicker::DEFAULT_ON_HIDE_JS_CALLBACK = DatePicker::DEFAULT_ON_CHANGED_JS_CALLBACK
end
class DatePickerAssetsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file "calendarview.js",  "public/javascripts/calendarview.js"
      m.file "calendarview.css", "public/stylesheets/calendarview.css"
      m.file "calendar_view_month.png", "public/images/calendar_view_month.png"
      m.directory "config/initializers"
      m.file "date_picker_config.rb", "config/initializers/date_picker_config.rb"
    end
  end
end

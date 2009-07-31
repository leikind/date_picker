# Include hook code here

ActionView::Base.class_eval do

  # Rails simple tag style view helpers  
  alias_method :original_select_date, :select_date
  alias_method :original_select_datetime, :select_datetime

  # Rails object-style view helpers
  alias_method :original_date_select, :date_select
  alias_method :original_datetime_select, :datetime_select

  
  include DatePicker 
  
end
module DatePicker

    def select_date_datetime_common(options, date_string)
      name = options[:prefix]

      hidden_input_field_id = options[:id] || name.gsub(/\]$/,'').gsub(/[\[\]]+/,'_')
      popup_trigger_icon_id = hidden_input_field_id + '_trigger'
      date_view_id = hidden_input_field_id + '_date_view'

      date_picker = %|<span class="date_picker">|
      date_picker << ' '
      date_picker << image_tag('calendar_view_month.png', :id => popup_trigger_icon_id, :style => 'cursor: pointer', :title => 'Date selector')

      date_picker << link_to_function(
        content_tag(:span, date_string, :id => date_view_id),
        %! $('#{date_view_id}').update('#{NIL_DATE_VIEW}'); $('#{hidden_input_field_id}').value = ''; !,
        :class => 'date_label',
        :title => DATE_STRING_TOOLTIP)

      date_picker << ' '
      date_picker << hidden_field_tag(name, date_string, :class => 'text-input', :id => hidden_input_field_id)
      date_picker << '</span>'

      return date_picker,  popup_trigger_icon_id, hidden_input_field_id, date_view_id
    end

    def calendar_constructor(popup_trigger_icon_id, hidden_input_field_id, date_format, date_view_id, with_time, on_hide, on_changed)
      js =  %|<script type="text/javascript">\n|
      js << %|  document.observe('dom:loaded', function(){\n|
      js << %|    new Calendar({\n|
      js << %|      triggerElement : "#{popup_trigger_icon_id}",\n|
      js << %|      dateField : "#{date_view_id}",\n|
      js << %|      dateFormat : "#{date_format}",\n|
      js << %|      extraOutputDateFields : $A([#{hidden_input_field_id}]),\n |
      js << %|      hideOnClickElsewhere : #{ALLOW_ONLY_ONE_POPUP_CALENDAR},\n |
      js << %|      minuteStep : #{MINUTE_STEP},\n |
      js << %|      onHideCallback : #{on_hide},\n | unless on_hide.blank?
      js << %|      onDateChangedCallback : #{on_changed},\n | unless on_changed.blank?
      js << %|      withTime : #{with_time}\n|
      js << %|    });\n|
      js << %|  });\n|
      js << %|</script>\n|

      js
    end

    def opt_process(opts)
      options = {:prefix => 'date', :on_hide => DEFAULT_ON_HIDE_JS_CALLBACK, :on_changed => DEFAULT_ON_CHANGED_JS_CALLBACK}
      opts.delete(:on_hide) if opts[:on_hide].blank?
      opts.delete(:on_changed) if opts[:on_changed].blank?
      options.merge!(opts)
      options
    end


    private :select_date_datetime_common, :calendar_constructor, :opt_process

    # Rails simple tag style view helpers
    def select_date(initial_date, opts = {}, html_opts = {})
      options = opt_process(opts)
      date_format = DATE_FORMAT
      date_string = initial_date.nil? ? NIL_DATE_VIEW : initial_date.strftime(date_format)

      html, popup_trigger_icon_id, hidden_input_field_id, date_view_id = select_date_datetime_common(options, date_string)

      html + calendar_constructor(
        popup_trigger_icon_id, hidden_input_field_id, date_format, date_view_id, 'false', options[:on_hide], options[:on_changed])
    end

    def select_datetime(initial_date, opts = {}, html_opts = {})
      options = opt_process(opts)
      date_format = DATETIME_FORMAT
      date_string = initial_date.nil? ? NIL_DATE_VIEW : initial_date.strftime(DATETIME_FORMAT)

      html, popup_trigger_icon_id, hidden_input_field_id, date_view_id = select_date_datetime_common(options, date_string)

      html + calendar_constructor(
        popup_trigger_icon_id, hidden_input_field_id, date_format, date_view_id, 'true', options[:on_hide], options[:on_changed])
    end


    # Rails object-style view helpers - just forming a call to tag style view helpers and reusing them
    def date_select(object_name, method, options = {})
      name = options[:name].nil? ? "#{object_name}[#{method}]" : options[:name]
      id = options[:id].nil? ? "#{object_name}_#{method}" : options[:id]
      it = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object))
      initial_date = it.object.send(method)
      select_date(initial_date, {:prefix => name, :id => id, :on_changed => options[:on_changed], :on_hide => options[:on_hide]})
    end

    def datetime_select(object_name, method, options = {})
      name = options[:name].nil? ? "#{object_name}[#{method}]" : options[:name]
      id = options[:id].nil? ? "#{object_name}_#{method}" : options[:id]
      it = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object))
      initial_date = it.object.send(method)
      select_datetime(initial_date, {:prefix => name, :id => id, :on_changed => options[:on_changed], :on_hide => options[:on_hide]})
    end

end

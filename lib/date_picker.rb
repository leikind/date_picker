module DatePicker

    def select_date_datetime_common(options, initial_date, with_time, date_format, date_format_hidden_field)
      
      date_string, date_string_for_hidden_field = if initial_date.nil? 
        [NIL_DATE_VIEW, NIL_DATE_VIEW]
      else
        [initial_date.strftime(date_format), initial_date.strftime(date_format_hidden_field)]
      end
      
      name = options[:prefix]

      hidden_input_field_id = options[:id] || name.gsub(/\]$/,'').gsub(/[\[\]]+/,'_')
      popup_trigger_icon_id = hidden_input_field_id + '_trigger'
      date_view_id = hidden_input_field_id + '_date_view'
      prompt_id = hidden_input_field_id + '_date_prompt'

      date_picker = %|<span class="date_picker">|
      date_picker << ' '
      date_picker << %|<span id="#{popup_trigger_icon_id}" class="trigger">|
      date_picker << image_tag('calendar_view_month.png', :title => 'Date selector')
      date_picker << %|<span class="prompt" id="#{prompt_id}">#{DatePicker::NIL_DATE_PROMPT}</span>|
      date_picker << %|</span>|
      
      date_picker << link_to_function(
        content_tag(:span, date_string, :id => date_view_id),
        %! $('#{date_view_id}').update('#{NIL_DATE_VIEW}'); $('#{hidden_input_field_id}').value = ''; $('#{prompt_id}').show(); !,
        :class => 'date_label',
        :title => DATE_STRING_TOOLTIP)

      date_picker << ' '
      date_picker << hidden_field_tag(name, date_string_for_hidden_field, :class => 'text-input', :id => hidden_input_field_id)
      date_picker << '</span>'

      date_picker << calendar_constructor(
        popup_trigger_icon_id, hidden_input_field_id, date_format, date_format_hidden_field, date_view_id, 
        with_time.to_s, options[:on_hide], options[:on_changed], prompt_id, initial_date)

      return date_picker
    end

    def calendar_constructor(popup_trigger_icon_id, hidden_input_field_id, date_format, 
                            date_format_hidden_field, date_view_id, with_time, 
                            on_hide, on_changed, prompt_id, initial_date)
      js =  %|<script type="text/javascript">\n|
      js << %|  document.observe('dom:loaded', function(){\n|
      js << %|    new Calendar({\n|
      js << %|      triggerElement : "#{popup_trigger_icon_id}",\n|
      js << %|      dateField : "#{date_view_id}",\n|
      js << %|      dateFormat : "#{date_format}",\n|
      js << %|      dateFormatForHiddenField : "#{date_format_hidden_field}",\n|
      js << %|      extraOutputDateFields : $A(["#{hidden_input_field_id}"]),\n |
      js << %|      hideOnClickElsewhere : #{ALLOW_ONLY_ONE_POPUP_CALENDAR},\n |
      js << %|      minuteStep : #{MINUTE_STEP},\n |
      js << %|      onHideCallback : function(date, calendar){ #{on_hide} },\n | 
      js << %|      onDateChangedCallback : function(date, calendar){ $("#{prompt_id}").hide(); #{on_changed} },\n | 
      js << %|      withTime : #{with_time}\n|
      js << %|    });\n|
      
      unless initial_date.nil?
        js << %|  $("#{prompt_id}").hide(); \n|
      end
      
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
      select_date_datetime_common(options, initial_date, false, DATE_FORMAT, DATE_FORMAT_HIDDEN_FIELD)
    end

    def select_datetime(initial_date, opts = {}, html_opts = {})
      options = opt_process(opts)
      select_date_datetime_common(options, initial_date, true, DATETIME_FORMAT, DATETIME_FORMAT_HIDDEN_FIELD)
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

module DatePicker

    def select_date_datetime_common(opts, initial_date, with_time, date_format, date_format_hidden_field)
      options = {
        :embedded => EMBEDDED_CALENDAR,
        :hide_on_click_on_day => HIDE_ON_CLICK_ON_DAY
      }
      options.merge!(opts)
      initial_date ||= options[:default]

      date_string = initial_date.nil? ? '' : initial_date.strftime(date_format_hidden_field)

      name = options[:prefix]

      hidden_input_field_id = options[:id] || name.gsub(/\]$/,'').gsub(/[\[\]]+/,'_')
      popup_trigger_icon_id = hidden_input_field_id + '_trigger'
      date_view_id = hidden_input_field_id + '_date_view'

      date_picker = %|<span class="date_picker">|
      date_picker << ' '
      date_picker << %|<span id="#{popup_trigger_icon_id}" class="trigger">|

      unless options[:embedded]
        date_picker << image_tag('calendar_view_month.png', :title => 'Date selector')
      end
      date_picker << %|</span>|

      date_picker << link_to_function(
        content_tag(:span, date_string, :id => date_view_id),
        %! $('#{date_view_id}').update(''); $('#{hidden_input_field_id}').value = ''; !,
        :class => 'date_label',
        :title => DATE_STRING_TOOLTIP) unless options[:embedded]

      date_picker << ' '
      date_picker << hidden_field_tag(name, date_string, :class => 'text-input', :id => hidden_input_field_id)
      date_picker << '</span>'

      date_picker << calendar_constructor(
        popup_trigger_icon_id, hidden_input_field_id, date_format, date_format_hidden_field, date_view_id,
        with_time.to_s, options[:on_hide], options[:on_changed], initial_date,
        options[:embedded], options[:hide_on_click_on_day], (initial_date.nil? ? false : true) )

      return date_picker
    end

    def datepicker_locale
      if Object.const_defined? :I18n
        I18n.locale || DatePicker::LANGUAGE
      else
        DatePicker::LANGUAGE
      end
    end

    def calendar_constructor(popup_trigger_icon_id, hidden_input_field_id, date_format,
                            date_format_hidden_field, date_view_id, with_time,
                            on_hide, on_changed, initial_date, embedded, hide_on_click_on_day, update_outer_fields_on_init)

      parent_or_trigger_definition = embedded ? 'embedAt' : 'popupTriggerElement'

      js = %|<script type="text/javascript">\n|

      if DatePicker.const_defined?('LANGUAGE') && ! @_date_picker_language_initialized
        js << %|    Calendar.language = '#{datepicker_locale}';\n|
        @_date_picker_language_initialized = true
      end

      js << %|  document.observe('dom:loaded', function(){\n|

      js << %|    new Calendar({\n|
      js << %|      #{parent_or_trigger_definition} : "#{popup_trigger_icon_id}",\n|

      if embedded
        js << %|      initialDate : $("#{hidden_input_field_id}").value,\n|
        js << %|      outputFields : $A(["#{hidden_input_field_id}"]),\n |
      else
        js << %|      initialDate : $("#{date_view_id}").innerHTML,\n|
        js << %|      outputFields : $A(["#{hidden_input_field_id}", "#{date_view_id}"]),\n |
      end

      if update_outer_fields_on_init
        js << %|      updateOuterFieldsOnInit : true,\n|
      end

      unless DatePicker::POPUP_PLACEMENT_STRATEGY == :trigger # :trigger is the default behavior 
                                                              # of Calendarview so we'll save a few bytes
                                                              # if POPUP_PLACEMENT_STRATEGY is :trigger
        js << %|      popupPositioningStrategy : "#{DatePicker::POPUP_PLACEMENT_STRATEGY}",\n|
      end

      js << %|       hideOnClickOnDay :  #{hide_on_click_on_day.inspect},\n | unless embedded

      js << %|      dateFormat : "#{date_format}",\n|
      js << %|      dateFormatForHiddenField : "#{date_format_hidden_field}",\n|
      js << %|      hideOnClickElsewhere : #{ALLOW_ONLY_ONE_POPUP_CALENDAR},\n |
      js << %|      minuteStep : #{MINUTE_STEP},\n |
      js << %|      onHideCallback : function(date, calendar){ #{on_hide} },\n |
      js << %|      onDateChangedCallback : function(date, calendar){  #{on_changed} },\n |
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
      select_date_datetime_common(options, initial_date, false, DATE_FORMAT, DATE_FORMAT_HIDDEN_FIELD)
    end

    def select_datetime(initial_date, opts = {}, html_opts = {})
      options = opt_process(opts)
      select_date_datetime_common(options, initial_date, true, DATETIME_FORMAT, DATETIME_FORMAT_HIDDEN_FIELD)
    end


    def object_style_to_tag_style(object_name, method, options = {})
      name = options[:name].nil? ? "#{object_name}[#{method}]" : options[:name]
      id = options[:id].nil? ? "#{object_name}_#{method}" : options[:id]
      it = ::ActionView::Helpers::InstanceTag.new(object_name, method, self, options.delete(:object))
      if it.object.nil? # Well, Rails helpers don't throw exceptions in this case, at least FormHelper helpers
        return [nil, nil]
      end
      initial_date = it.object.send(method)

      opts = {:prefix => name,
       :id => id,
       :on_changed => options[:on_changed],
       :on_hide => options[:on_hide],
       :default => options[:default]
      }
      opts[:embedded] = options[:embedded] if options.has_key?(:embedded)
      opts[:hide_on_click_on_day] = options[:hide_on_click_on_day] if options.has_key?(:hide_on_click_on_day)

      return initial_date, opts
    end

    # Rails object-style view helpers - just forming a call to tag style view helpers and reusing them
    def date_select(object_name, method, options = {}, html_options = {})
      initial_date, opts = object_style_to_tag_style(object_name, method, options)
      if opts.nil?
        ''
      else
        select_date(initial_date, opts)
      end
    end

    def datetime_select(object_name, method, options = {}, html_options = {})
      initial_date, opts = object_style_to_tag_style(object_name, method, options)
      if opts.nil?
        ''
      else
        select_datetime(initial_date, opts)
      end
    end
end

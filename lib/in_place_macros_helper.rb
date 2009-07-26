module InPlaceMacrosHelper
  # Makes an HTML element specified by the DOM ID +field_id+ become an in-place
  # editor of a property.
  #
  # A form is automatically created and displayed when the user clicks the element,
  # something like this:
  #   <form id="myElement-in-place-edit-form" target="specified url">
  #     <input name="value" text="The content of myElement"/>
  #     <input type="submit" value="ok"/>
  #     <a onclick="javascript to cancel the editing">cancel</a>
  #   </form>
  #
  # The form is serialized and sent to the server using an AJAX call, the action on
  # the server should process the value and return the updated value in the body of
  # the reponse. The element will automatically be updated with the changed value
  # (as returned from the server).
  #
  # Required +options+ are:
  # <tt>:url</tt>::       Specifies the url where the updated value should
  #                       be sent after the user presses "ok".
  #
  # Addtional +options+ are:
  # <tt>:rows</tt>::                  Number of rows (more than 1 will use a TEXTAREA)
  # <tt>:cols</tt>::                  Number of characters the text input should span (works for both INPUT and TEXTAREA)
  # <tt>:size</tt>::                  Synonym for :cols when using a single line text input.
  # <tt>:cancel_text</tt>::           The text on the cancel link. (default: "cancel")
  # <tt>:save_text</tt>::             The text on the save link. (default: "ok")
  # <tt>:loading_text</tt>::          The text to display while the data is being loaded from the server (default: "Loading...")
  # <tt>:saving_text</tt>::           The text to display when submitting to the server (default: "Saving...")
  # <tt>:save_control</tt>::          The type of control to use for the save button: button, link, false for none at all
  # <tt>:cancel_control</tt>::        The type of control to use for the save button: button, link, false for none at all
  # <tt>:external_control</tt>::      Disables onclick editing so that only an external control can activate editable mode
  # <tt>:external_control_only</tt>:: The id of an external control used to enter edit mode.
  # <tt>:load_text_url</tt>::         URL where initial value of editor (content) is retrieved.
  # <tt>:highlight_color</tt>::       The hexadecimal color to highlight the unclicked control when hovered over
  # <tt>:highlight_end_color</tt>::   The hexadecimal color to highlight ends on the unclicked control when hovered over
  # <tt>:saving_class</tt>::          The CSS class to apply to the control when the user has clicked the save button
  # <tt>:form_class</tt>::            The CSS class to apply to the overall form
  # <tt>:hover_class</tt>::           The CSS class to apply to the control when it is hovered over
  # <tt>:oncomplete</tt>::            JavaScript snippet that is evaluated when the save is successful
  # <tt>:onfailure</tt>::             JavaScript snippet that is evaluated when the save is unsucessful
  # <tt>:options</tt>::               Pass through options to the AJAX call (see prototype's Ajax.Updater)
  # <tt>:with</tt>::                  JavaScript snippet that should return what is to be sent
  #                                   in the AJAX call, +form+ is an implicit parameter
  # <tt>:script</tt>::                Instructs the in-place editor to evaluate the remote JavaScript response (default: false)
  # <tt>:click_to_edit_text</tt>::    The text shown during mouseover the editable text (default: "Click to edit")
  #
  # To create an InPlaceCollectionEditor pass:
  # <tt>:collection</tt>::  An enumerable, typically an array or two-dimensional array
  #
  # Additional options for InPlaceCollectionEditor:
  # <tt>:load_collection_url</tt>::   URL where a collection can be retrieved via AJAX
  # <tt>:load_collection_text</tt>::  The message to display when collection is being retrieved from +:load_collection_url+
  # <tt>:load_class</tt>::            The class name applied when collection is being retrieved from +:load_collection_url+
  # <tt>:value</tt>::                 The key to use when selecting an option from the select (or the value when clicked on)

  def in_place_editor(field_id, options = {})
    collection = options[:collection] && 'Collection'

    function =  "new Ajax.InPlace#{collection}Editor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}

    if protect_against_forgery?
      options[:with] ||= "Form.serialize(form)"
      options[:with] += " + '&authenticity_token=' + encodeURIComponent('#{form_authenticity_token}')"
    end

    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['htmlResponse'] = !options[:script] if options[:script]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    js_options['textBetweenControls'] = %('#{options[:text_between_controls]}') if options[:text_between_controls]

    # v1.5 Options
    js_options['value'] = options[:value] if options[:value]
    js_options['okControl'] = %('#{options[:save_control]}') if options[:save_control]
    js_options['cancelControl'] = %('#{options[:cancel_control]}') if options[:cancel_control]
    js_options['externalControlOnly'] = 'true' if options[:external_control_only]
    js_options['highlightcolor'] = %('#{options[:highlight_color]}') if options[:highlight_color]
    js_options['highlightendcolor'] = %('#{options[:highlight_end_color]}') if options[:highlight_end_color]
    js_options['savingClassName'] = %('#{options[:saving_class]}') if options[:saving_class]
    js_options['formClassName'] = %('#{options[:form_class]}') if options[:form_class]
    js_options['hoverClassName'] = %('#{options[:hover_class]}') if options[:hover_class]

    # callbacks
    js_options['onComplete'] = options[:oncomplete] if options[:oncomplete]
    js_options['onFailure'] = options[:onfailure] if options[:onfailure]

    # InPlaceCollectionOptions
    js_options['collection'] = options[:collection].to_json if options[:collection]
    js_options['loadCollectionURL'] = "'#{url_for(options[:load_collection_url])}'" if options[:load_collection_url]
    js_options['loadingCollectionText'] = %('#{options[:load_collection_text]}') if options[:load_collection_text]
    js_options['loadingClassName'] = %('#{options[:load_class]}') if options[:load_class]

    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    function << ')'

    javascript_tag(function)
  end

  # Renders the value of the specified object and method with in-place editing capabilities.
  def in_place_editor_field(object, method, tag_options = {}, in_place_editor_options = {})
    instance_tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span",
                   :id => "#{object}_#{method}_#{instance_tag.object.id}_in_place_editor",
                   :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => instance_tag.object.id })
    value = tag_options.delete(:display) || instance_tag.value(instance_tag.object)
    tag = content_tag(tag_options.delete(:tag), h(value), tag_options)
    return tag + in_place_editor(tag_options[:id], in_place_editor_options)
  end
end

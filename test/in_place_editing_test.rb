require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class InPlaceEditingTest < ActionController::TestCase
  include InPlaceEditing
  include InPlaceMacrosHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper

  include ActionController::Assertions::DomAssertions

  def setup
    @controller = Class.new do
      def url_for(options)
        url =  "http://www.example.com/"
        url << options[:action].to_s if options and options[:action]
        url
      end
    end
    @controller = @controller.new
    @protect_against_forgery = false
  end

  def protect_against_forgery?
    @protect_against_forgery
  end

  def test_in_place_editor_external_control
      assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Ajax.InPlaceEditor('some_input', 'http://www.example.com/inplace_edit', {externalControl:'blah'})\n//]]>\n</script>),
        in_place_editor('some_input', {:url => {:action => 'inplace_edit'}, :external_control => 'blah'})
  end

  def test_in_place_editor_size
      assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Ajax.InPlaceEditor('some_input', 'http://www.example.com/inplace_edit', {size:4})\n//]]>\n</script>),
        in_place_editor('some_input', {:url => {:action => 'inplace_edit'}, :size => 4})
  end

  def test_in_place_editor_cols_no_rows
      assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Ajax.InPlaceEditor('some_input', 'http://www.example.com/inplace_edit', {cols:4})\n//]]>\n</script>),
        in_place_editor('some_input', {:url => {:action => 'inplace_edit'}, :cols => 4})
  end

  def test_in_place_editor_cols_with_rows
      assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Ajax.InPlaceEditor('some_input', 'http://www.example.com/inplace_edit', {cols:40, rows:5})\n//]]>\n</script>),
        in_place_editor('some_input', {:url => {:action => 'inplace_edit'}, :rows => 5, :cols => 40})
  end

  def test_inplace_editor_loading_text
      assert_dom_equal %(<script type=\"text/javascript\">\n//<![CDATA[\nnew Ajax.InPlaceEditor('some_input', 'http://www.example.com/inplace_edit', {loadingText:'Why are we waiting?'})\n//]]>\n</script>),
        in_place_editor('some_input', {:url => {:action => 'inplace_edit'}, :loading_text => 'Why are we waiting?'})
  end

  def test_in_place_editor_url
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/action_to_set_value')",
    in_place_editor( 'id-goes-here', :url => { :action => "action_to_set_value" })
  end

  def test_in_place_editor_load_text_url
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/action_to_set_value', {loadTextURL:'http://www.example.com/action_to_get_value'})",
    in_place_editor( 'id-goes-here',
      :url => { :action => "action_to_set_value" },
      :load_text_url => { :action => "action_to_get_value" })
  end

  def test_in_place_editor_html_response
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/action_to_set_value', {htmlResponse:false})",
    in_place_editor( 'id-goes-here',
      :url => { :action => "action_to_set_value" },
      :script => true )
  end

  def form_authenticity_token
    "authenticity token"
  end

  def test_in_place_editor_with_forgery_protection
    @protect_against_forgery = true
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/action_to_set_value', {callback:function(form) { return Form.serialize(form) + '&authenticity_token=' + encodeURIComponent('authenticity token') }})",
    in_place_editor( 'id-goes-here', :url => { :action => "action_to_set_value" })
  end

  def test_in_place_editor_text_between_controls
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/action_to_set_value', {textBetweenControls:'or'})",
    in_place_editor( 'id-goes-here',
      :url => { :action => "action_to_set_value" },
      :text_between_controls => "or" )
  end

  def test_inplace_editor_value
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {value:1})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :value => 1 )
  end

  def test_inplace_editor_save_control
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {okControl:'button'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :save_control => :button )
  end

  def test_inplace_editor_save_control
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {cancelControl:'button'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :cancel_control => :button )
  end

  def test_inplace_editor_external_control_only
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {externalControlOnly:true})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :external_control_only => true )
  end

  def test_inplace_editor_highlight_color
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {highlightcolor:'#C0FFEE'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :highlight_color => '#C0FFEE' )
  end

  def test_inplace_editor_highlight_color_end
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {highlightendcolor:'#C0FFEE'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :highlight_end_color => '#C0FFEE' )
  end

  def test_inplace_editor_saving_class
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {savingClassName:'save'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :saving_class => 'save' )
  end

  def test_inplace_editor_form_class
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {formClassName:'edit'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :form_class => 'edit' )
  end

  def test_inplace_editor_hover_class
    assert_match "Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {hoverClassName:'underline'})",
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :hover_class => 'underline' )
  end

  def test_inplace_editor_oncomplete
    assert_match %[Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {onComplete:alert("Yo!")})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :oncomplete => 'alert("Yo!")' )
  end

  def test_inplace_editor_onfailure
    assert_match %[Ajax.InPlaceEditor('id-goes-here', 'http://www.example.com/inplace_edit', {onFailure:alert("Fail!")})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :onfailure => 'alert("Fail!")' )
  end

  # InPlaceCollectionEditor

  def test_inplace_collection_editor
    assert_match %[Ajax.InPlaceCollectionEditor('id-goes-here', 'http://www.example.com/inplace_edit', {collection:["a", "b", "c"]})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :collection => %w[a b c] )
  end

  def test_inplace_collection_editor_with_2d_array
    assert_match %[Ajax.InPlaceCollectionEditor('id-goes-here', 'http://www.example.com/inplace_edit', {collection:[[0, "No"], [1, "Yes"]]})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :collection => [[0,'No'],[1,'Yes']] )
  end

  def test_inplace_collection_editor_load_collection_url
    assert_match %[Ajax.InPlaceCollectionEditor('id-goes-here', 'http://www.example.com/inplace_edit', {collection:["a", "b", "c"], loadCollectionURL:'http://www.example.com/load_collection'})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :collection => %w[a b c], :load_collection_url => {:action => 'load_collection'} )
  end

  def test_inplace_collection_editor_load_collection_text
    assert_match %[Ajax.InPlaceCollectionEditor('id-goes-here', 'http://www.example.com/inplace_edit', {collection:["a", "b", "c"], loadingCollectionText:'Loading...'})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :collection => %w[a b c], :load_collection_text => 'Loading...' )
  end

  def test_inplace_collection_editor_load_class
    assert_match %[Ajax.InPlaceCollectionEditor('id-goes-here', 'http://www.example.com/inplace_edit', {collection:["a", "b", "c"], loadingClassName:'rotate'})],
    in_place_editor( 'id-goes-here', :url => { :action => 'inplace_edit' }, :collection => %w[a b c], :load_class => 'rotate' )
  end
end
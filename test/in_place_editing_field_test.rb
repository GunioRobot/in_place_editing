require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class InPlaceEditingFieldTest < ActionController::TestCase
  include InPlaceEditing
  include InPlaceMacrosHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::CaptureHelper

  include ActionController::Assertions::DomAssertions

  def setup
    @object = Class.new do
      def name() 'test' end
      def id() 123 end
    end
    @object = @object.new
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

  def test_in_place_editor_field
    assert_match %[<span class="in_place_editor_field" id="object_name_123_in_place_editor">test</span>],
    in_place_editor_field(:object, :name)
  end

  def test_in_place_editor_field_default_url
    assert_match "Ajax.InPlaceEditor('object_name_123_in_place_editor', 'http://www.example.com/set_object_name')",
    in_place_editor_field(:object, :name)
  end

  def test_in_place_editor_field_custom_url
    assert_match "Ajax.InPlaceEditor('object_name_123_in_place_editor', 'http://www.example.com/custom')",
    in_place_editor_field(:object, :name, {}, :url => {:action => 'custom'})
  end

  def test_in_place_editor_field_with_tag
    assert_match %[<div class="in_place_editor_field" id="object_name_123_in_place_editor">test</div>],
    in_place_editor_field(:object, :name, :tag => :div)
  end

  def test_in_place_editor_field_with_id
    assert_match %[<span class="in_place_editor_field" id="my_field">test</span>],
    in_place_editor_field(:object, :name, :id => 'my_field')
  end

  def test_in_place_editor_field_with_class
    assert_match %[<span class="my_field" id="object_name_123_in_place_editor">test</span>],
    in_place_editor_field(:object, :name, :class => 'my_field')
  end

  def test_in_place_editor_field_with_display
    assert_match %[<span class="in_place_editor_field" id="object_name_123_in_place_editor">Show This Instead</span>],
    in_place_editor_field(:object, :name, :display => 'Show This Instead')
  end

  def test_in_place_editor_field_value_is_html_encoded
    assert_match %[<span class="in_place_editor_field" id="object_name_123_in_place_editor">Rock &amp; Paper</span>],
    in_place_editor_field(:object, :name, :display => 'Rock & Paper')
  end

  def test_in_place_editor_field_value_passes_html_options
    assert_match %[<span class="in_place_editor_field" id="object_name_123_in_place_editor" style="color:red">test</span>],
    in_place_editor_field(:object, :name, :style => 'color:red')
  end
end
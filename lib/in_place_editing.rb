module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  # # Options to pass to +in_place_edit_for+
  # <tt>:display</tt>::         A method to send to the object instead of #to_s when returning a saved value
  # <tt>:no_association</tt>::  Prevents associations from being traversed and assigned (to allow direct manipulation)
  #
  # Note: Currently only +belongs_to+ and +has_one+ associations will be set with an +id+ if in_place_edit_for
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end

        @item = object.to_s.camelize.constantize.find(params[:id])

        with_association = !options[:no_association] # only true will quick fail
        unless with_association && self.class.in_place_edit_association_for(@item, attribute, params[:value]) then
          @item.update_attribute(attribute, params[:value])
        end

        render :text => CGI::escapeHTML(@item.send(attribute).send(options[:display]||:to_s))
      end
    end

    def in_place_edit_association_for(item, attribute, value)
      return unless reflection = item.class.reflect_on_association(attribute.to_sym)
      case reflection.macro
      when :belongs_to, :has_one
        item.update_attribute(attribute, reflection.klass.find(value))
      end
    end
  end
end

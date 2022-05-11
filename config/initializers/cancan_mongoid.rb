module CanCan
  class Query
    def sanitize_sql(conditions)
      conditions
    end
  end

  # customize to handle Mongoid queries in ability definitions conditions
  class CanDefinition
    def matches_conditions_hash?(subject, conditions = @conditions)          
      if subject.class.include?(Mongoid::Document)        # Mongoid Criteria are simpler to check than normal conditions hashes
        if conditions.empty?  # The active_record code below is based on this obscure ruby behavior: 
                              #   {}.all?{|a| a == 5} 
                              # => true
                              #   {}.all?{|a| a =! 5} 
                              # => true
          true
        else
          subject.class.where(conditions).include?(subject)  # just use Mongoid's where function
        end
      else 
        conditions.all? do |name, value|
          attribute = subject.send(name)
          if value.kind_of?(Hash)
            if attribute.kind_of? Array
              attribute.any? { |element| matches_conditions_hash? element, value }
            else
              matches_conditions_hash? attribute, value
            end
          elsif value.kind_of?(Array) || value.kind_of?(Range)
            value.include? attribute
          else
            attribute == value
          end
        end
      end
    end
  end

  # This module is automatically included into all Mongoid
  module MongoidAdditions
    module ClassMethods
      # Returns a scope which fetches only the records that the passed ability
      # can perform a given action on. The action defaults to :read. This
      # is usually called from a controller and passed the +current_ability+.
      #
      #   @articles = Article.accessible_by(current_ability)
      # 
      # Here only the articles which the user is able to read will be returned.
      # If the user does not have permission to read any articles then an empty
      # result is returned. Since this is a scope it can be combined with any
      # other scopes or pagination.
      # 
      # An alternative action can optionally be passed as a second argument.
      # 
      #   @articles = Article.accessible_by(current_ability, :update)
      # 
      # Here only the articles which the user can update are returned. This
      # internally uses Ability#conditions method, see that for more information.
      def accessible_by(ability, action = :read)
        query = ability.query(action, self)        
        where(query.conditions)
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
    end
  end
    
  class ControllerResource # :nodoc:
    def authorize_resource
      @controller.authorize!(authorization_action, resource_instance || resource_class)
    end
  end    
end

# Info on monkeypatching Mongoid : 
# http://log.mazniak.org/post/719062325/monkey-patching-activesupport-concern-and-you#footer
if defined? Mongoid
  module Mongoid
    module Components
      old_block = @_included_block
      @_included_block = Proc.new do 
        class_eval(&old_block) if old_block
        include CanCan::MongoidAdditions
      end
    end
  end  
end
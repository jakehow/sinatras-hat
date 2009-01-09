module Sinatra
  module Hat
    class Responder
      delegate :model, :to => :maker
      
      attr_reader :maker
      
      def initialize(maker)
        @maker = maker
      end
      
      def handle(name, request, data)
        request.params[:format] ? serialize(request, data) : render(name, request, data)
      end
      
      def serialize(request, data)
        name = request.params[:format].to_sym
        maker.formats[name] ||= to_format(name)
        maker.formats[name][data]
      end
      
      def redirect(request, path)
        request.redirect(path)
      end
      
      def render(name, request, data)
        request.instance_variable_set(ivar_name(data), data)
        request.erb name.to_sym, :views_directory => File.join(request.options.views, maker.prefix)
      end
      
      private
      
      def ivar_name(data)
        "@" + (data.respond_to?(:each) ? model.plural : model.singular)
      end
      
      def to_format(name)
        @default_formatter ||= Proc.new { |data| data.send("to_#{name}") }
      end
    end
  end
end
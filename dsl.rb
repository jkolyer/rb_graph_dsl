require 'ostruct'

module GraphConfig
  @registry = {}

  def self.registry
    @registry
  end

  def self.raise_invalid_attrs(*attrs)
    raise ArgumentError("unexpected attribute #{attrs}")
  end

  def self.configure(&block)
    graph_proxy = GraphProxy.new
    graph_proxy.instance_eval(&block)
  end

  def self.build(graph_id, overrides = {})
    proxy = registry[graph_id]
    instance = proxy[:graph_class].new
    
    proxy.config_value_hash(overrides).each do |attr, value|
      meth_name = "#{attr}="
      GraphConfig.raise_invalid_attr(attr) unless instance.respond_to?(meth_name)
      instance.send(meth_name, value)
    end
    instance
  end

  def self.build_ids(ids, overrides = {})
    ids.map do |graph_id|
      self.build(graph_id, overrides)
    end
  end

  def self.build_all(overrides = {})
    build_ids(registry.keys, overrides)
  end

  class GraphProxy
    class Proxy < OpenStruct
      @@private_attrs = [:config_attrs, :graph_class]
      
      def initialize(config_attrs)
        super()
        self[:config_attrs] = config_attrs
      end

      def method_missing(attr, *args, &block)        
        # when we do instance_eval, properties
        # are registered here with corresponding value
        
        # first check white list and ignore invalid properties
        GraphConfig.raise_invalid_attr(attr) if self[:config_attrs].index(attr).nil?

        # saves attr and value locally
        self[attr] = args.size > 0 ? args[0] : block
      end

      def config_value_hash(overrides)
        attrs = self.to_h.merge(overrides)
        config_attrs = self[:config_attrs]
        
        # we only expect config_attrs and private_attrs in the diff
        attr_diff = attrs.keys - config_attrs - @@private_attrs
        GraphConfig.raise_invalid_attr(attr_diff) if attr_diff.size > 0

        # we disallow nil config values 
        attrs.delete_if { |key,val| config_attrs.index(key).nil? }
        return attrs
      end
    end
    
    def config(graph_class, &block)
      # the graph class is expected to provide whitelist of attributes to configure
      proxy = Proxy.new(graph_class.config_attrs)
      proxy.instance_eval(&block)

      # save this for the build process
      proxy[:graph_class] = graph_class
      
      GraphConfig.registry[proxy.id] = proxy
    end
  end
  
  module GraphSettings
    @settings_attrs = [:track_performance]
    
    def self.settings_attrs
      @settings_attrs
    end

    class SettingsProxy < OpenStruct
      def method_missing(attr, *args, &block)
        # first check white list and ignore invalid properties
        GraphConfig.raise_invalid_attr(attr) if GraphSettings.settings_attrs.index(attr).nil?
        # saves attr and value locally
        self[attr] = args.size > 0 ? args[0] : block
      end
    end
    
    @settings = SettingsProxy.new

    def self.settings_values
      @settings
    end

    def self.configure(&block)
      @settings.instance_eval(&block)
    end

    def self.track_performance
      @settings[:track_performance]
    end
  end
end


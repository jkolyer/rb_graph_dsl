require 'logger'
class AlgorithmResultError < StandardError; end

class Graph
  @config_attrs = [:id, :node_count, :edges, :directed, :algorithm, :expected_result].freeze
  @no_expected_result = Object.new

  def self.config_attrs
    @config_attrs
  end
  attr_accessor(*self.config_attrs)

  @@logger = Logger.new(STDOUT)

  def initialize
    # this value is not required
    self.expected_result = @no_expected_result
    # we default to directed graph
    self.directed = true
  end

  def to_s
    "#{self.class.name}(#{id}): #{node_count} nodes"
  end

  def run_algorithm
    raise ArgumentError.new("Found nil argument #{self.class.config_attrs}") \
      if self.class.config_attrs.map{|at| send(at)}.any?(nil)

    log_perf { "start #{id}" } 
    result = send(algorithm)
    log_perf { "finish #{id}:  result = #{result}" } 
    
    if _has_expected_result? && result != expected_result
      raise AlgorithmResultError.new("#{algorithm} expecting #{expected_result}; instead got #{result}")
    end
    result
  end

  ############
  # Algorithms
  ############
  
  def has_cycle?
    directed ? _directed_has_cycle? : _undirected_has_cycle?
  end

  def topological_sort
    raise ArgumentError.new() unless directed
    _topological_sort
  end

  #########
  protected
  #########

  def log_perf(&block)
    @@logger.info(&block) if GraphConfig::GraphSettings.track_performance
  end

  def _init_node_count_false_array
    Array.new(node_count, false)
  end

  def _has_expected_result?
    self.expected_result != @no_expected_result
  end

  def _adj_list
    return @adj_list if @adj_list
    
    @adj_list = edges.reduce({}) do |hash, edge|
      src, dest = edge
      adj_val = hash[src] || []
      adj_val << dest
      hash[src] = adj_val
      
      unless directed
        adj_val = hash[dest] || []
        adj_val << src
        hash[dest] = adj_val
      end
      hash
    end
    @adj_list.default = []
    @adj_list
  end

  def _directed_has_cycle?
    @visited = _init_node_count_false_array
    @in_path = _init_node_count_false_array
    @has_cycle = false
    
    def _dfs_cycle(vtx)
      @visited[vtx] = true
      @in_path[vtx] = true
      
      _adj_list[vtx].each do |adj_vtx|
        break if @has_cycle
        if @in_path[adj_vtx]
          @has_cycle = true
          break
        end
        next if @visited[adj_vtx]
        _dfs_cycle(adj_vtx)
      end
      @in_path[vtx] = false
    end
    _dfs_cycle(0)
    @has_cycle
  end

  def _undirected_has_cycle?
    @visited = _init_node_count_false_array
    @parent = _init_node_count_false_array
    @has_cycle = false
    
    def _dfs_cycle(vtx)
      @visited[vtx] = true
      
      _adj_list[vtx].each do |adj_vtx|
        break if @has_cycle
        
        if @visited[adj_vtx]
          @has_cycle = true if @parent[vtx] != adj_vtx
        else
          @parent[adj_vtx] = vtx
          _dfs_cycle(adj_vtx)
        end
      end
    end
    
    _dfs_cycle(0)
    @has_cycle
  end

  def _topological_sort
    @visited = _init_node_count_false_array
    @topo_stack = []

    def _dfs_topo_sort(vtx)
      @visited[vtx] = true
      return @topo_stack << vtx if _adj_list[vtx].empty?

      _adj_list[vtx].each do |adj_vtx|
        next if @visited[adj_vtx]
        _dfs_topo_sort(adj_vtx)
      end
      @topo_stack << vtx
    end
    
    (0...node_count).each do |vtx|
      next if @visited[vtx]
      _dfs_topo_sort(vtx) 
    end
    @topo_stack.reverse    
  end

end


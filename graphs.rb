class AlgorithmResultError < StandardError; end

class Graph
  @config_attrs = [:id, :node_count, :edges, :directed, :algorithm, :expected_value].freeze
  @no_expected_value = Object.new
  
  def self.config_attrs
    @config_attrs
  end
  attr_accessor(*self.config_attrs)

  def initialize
    # this value is not required
    self.expected_value = @no_expected_value
    # we default to directed graph
    self.directed = true
  end

  def to_s
    "#{self.class.name}(#{id}): #{node_count} nodes"
  end

  def run_algorithm
    raise ArgumentError.new("Found nil argument #{self.class.config_attrs}") \
      if self.class.config_attrs.map{|at| send(at)}.any?(nil)

    result = send(algorithm)
    
    if _has_expected_value? && result != expected_value
      raise AlgorithmResultError.new("#{algorithm} expecting #{expected_value}; instead got #{result}")
    end
    result
  end

  def has_cycle?
    directed ? _directed_has_cycle? : _undirected_has_cycle?
  end

  def topological_sort
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

  #########
  protected
  #########

  def _init_node_count_false_array
    Array.new(node_count, false)
  end

  def _has_expected_value?
    self.expected_value != @no_expected_value
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

end


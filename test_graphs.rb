require_relative "graphs"
require_relative "dsl"
require "test/unit"
 
class TestGraphs < Test::Unit::TestCase

  def setup
    GraphConfig.configure do
      config Graph do
        id :dag_has_cycle_true
        directed true
        algorithm :has_cycle?
        node_count 7
        edges [[0,1],[0,2],[1,4],[2,3],[3,1],[3,5],[4,6],[5,4],[6,5]]
        expected_result true
      end
      config Graph do
        id :dag_has_cycle_false
        directed true
        algorithm :has_cycle?
        node_count 5
        edges [[0,1],[0,2],[2,3],[3,4],[4,1]]
        expected_result false
      end
      config Graph do
        id :uag_has_cycle_false
        directed false
        algorithm :has_cycle?
        node_count 7
        edges [[0,1],[0,2],[2,3],[2,4],[4,5],[4,6]]
        expected_result false
      end
      config Graph do
        id :uag_has_cycle_true
        directed false
        algorithm :has_cycle?
        node_count 4
        edges [[0,1],[0,2],[1,3],[2,3]]
        expected_result true
      end
      config Graph do
        id :topo_sort
        directed true
        algorithm :topological_sort
        node_count 7
        edges [[0,2],[0,5],[1,3],[1,6],[2,4],[3,5],[5,2],[5,4],[6,2]]
        expected_result [1, 6, 3, 0, 5, 2, 4]
      end
    end
  end

  # tests
  # no expected value
  # raise exception when unknown attrs
  # undirected graphs
  # all variations of build*
 
  def test_graph_builds
    graph = GraphConfig.build(:dag_has_cycle_true)
    assert_not_nil(graph)
    # add validation tests between proxy values and graph values
    
    graphs = GraphConfig.build_all()
    assert_equal(graphs.size, GraphConfig.registry.size)
  end

  def test_attribute_whitelist
    # throw exception instead of ignoring unknown attrs
  end
 
  def test_graph_run_dag_has_cycle
    assert_nothing_raised do
      GraphConfig.build(:dag_has_cycle_true).run_algorithm
    end
    assert_nothing_raised do
      GraphConfig.build(:dag_has_cycle_false).run_algorithm
    end
  end
 
  def test_graph_run_uag_has_cycle
    assert_nothing_raised do
      GraphConfig.build(:uag_has_cycle_false).run_algorithm
    end
    assert_nothing_raised do
      GraphConfig.build(:uag_has_cycle_true).run_algorithm
    end
  end
 
  def test_graph_run_topo_sort
    assert_nothing_raised do
      GraphConfig.build(:topo_sort).run_algorithm
    end
  end
 
end

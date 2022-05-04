# Ruby DSL for graph algorithms

This repo serves as an example for DSL design in Ruby, and a testbed for graph algorithm development. 

## DSL 
The approach used here creates a configuration proxy for individual graph algorthims; in addition top-level settings such as logging are configured for all individual graphs.  

The graph properties being configured include 

* descriptive identifier
* node count
* edges
* directed graph boolean
* algorithm method name
* optional expected result

We create a proxy object which contains a graph's properties and store that for lookup by identifier when the graph's algorithm is executed.  

The configuration properties are not hard-coded into the DSL.  Instead the graph class is expected to provide a static method [**config_attrs**](https://github.com/jkolyer/rb_graph_dsl/blob/master/graphs.rb#L8) as a white list of allowed properties.  This approach allows decoupling between the DSL and the user-defined base graph class.

The proxy object subclasses [_OpenStruct_](https://ruby-doc.org/stdlib-3.1.2/libdoc/ostruct/rdoc/OpenStruct.html) and overrides **[method_missing](https://ruby-doc.org/core-2.6.3/BasicObject.html#method-i-method_missing)**.  This provides us with a "blank slate" style object and, using an attribute whitelist, a safe implementation of **method_missing** – note that relying on this technique can be tricky, but our approach simplifies it.

## Graph Algorithms

This repo implements two standard graph algorithms

* has_cycle
* topological_sort

Adding additional algorithms can be done by adding a method, and configuring a graph with the method name.

See the [**test_graphs.rb**](https://github.com/jkolyer/rb_graph_dsl/blob/master/test_graphs.rb) file for more details. 

Pull requests are welcome.

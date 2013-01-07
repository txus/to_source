require 'set'
require 'melbourne'
require 'adamantium'
require 'abstract_type'
require 'equalizer'
require 'to_source/command'
require 'to_source/state'
require 'to_source/emitter'
require 'to_source/emitter/literal'
require 'to_source/emitter/access'
require 'to_source/emitter/formal_arguments'
require 'to_source/emitter/actual_arguments'
require 'to_source/emitter/scope'
require 'to_source/emitter/define'
require 'to_source/emitter/assignment'
require 'to_source/emitter/static'
require 'to_source/emitter/block'
require 'to_source/emitter/toplevel'
require 'to_source/emitter/keyword_value'
require 'to_source/emitter/execute_string'
require 'to_source/emitter/singleton_class'
require 'to_source/emitter/empty_body'
require 'to_source/emitter/rescue_condition'
require 'to_source/emitter/rescue'
require 'to_source/emitter/ensure_body'
require 'to_source/emitter/scope_name'
require 'to_source/emitter/nth_ref'
require 'to_source/emitter/scoped_name'
require 'to_source/emitter/send'
require 'to_source/emitter/send_with_arguments'
require 'to_source/emitter/block_pass'
require 'to_source/emitter/iter'
require 'to_source/emitter/pattern_arguments'
require 'to_source/emitter/block_argument'
require 'to_source/emitter/unary_operator_method'
require 'to_source/emitter/binary_operator_method'
require 'to_source/emitter/binary_operator'
require 'to_source/emitter/element_reference'
require 'to_source/emitter/to_array'
require 'to_source/emitter/to_string'
require 'to_source/emitter/defined'
require 'to_source/emitter/attribute_assignment'
require 'to_source/emitter/element_assignment'
require 'to_source/emitter/if'
require 'to_source/emitter/while'
require 'to_source/emitter/ensure'
require 'to_source/emitter/receiver_case'
require 'to_source/emitter/when'
require 'to_source/emitter/splat_when'
require 'to_source/emitter/unless'
require 'to_source/emitter/until'
require 'to_source/emitter/class'
require 'to_source/emitter/module'
require 'to_source/emitter/op_assign2'
require 'to_source/emitter/op_assign1'
require 'to_source/emitter/z_super'
require 'to_source/emitter/default_arguments'
require 'to_source/emitter/multiple_assignment'
require 'to_source/emitter/concat_arguments'
require 'to_source/emitter/super'
require 'to_source/emitter/match3'
require 'to_source/emitter/yield'
require 'to_source/emitter/alias'
require 'to_source/emitter/splat'
require 'to_source/emitter/begin'
require 'to_source/emitter/util'

# Library namespace
module ToSource

  # Convert node to string
  #
  # @param [Rubinius::AST::Node] node
  #
  # @return [String]
  #
  # @api private
  #
  def self.to_source(node)
    Emitter.run(node)
  end

end

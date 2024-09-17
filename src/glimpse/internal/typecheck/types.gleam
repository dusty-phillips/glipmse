import glance
import gleam/dict.{type Dict}
import gleam/iterator
import gleam/list
import gleam/option
import gleam/string_builder
import glimpse/error

pub type Type {
  NilType
  IntType
  FloatType
  StringType
  BoolType
  CustomType(name: String)
  CallableType(
    /// All parameters (labelled or otherwise)
    parameters: List(Type),
    /// Map of label to its position in parameters list
    position_labels: Dict(String, Int),
    return: Type,
  )
  /// Used for field access on imports; no direct glance analog
  NamespaceType(Dict(String, Type))
}

pub type TypeResult =
  error.TypeCheckResult(Type)

pub fn to_string(type_: Type) -> String {
  case type_ {
    NilType -> "Nil"
    IntType -> "Int"
    FloatType -> "Float"
    StringType -> "String"
    BoolType -> "Bool"
    CustomType(name) -> name
    CallableType(parameters, _labels, return) ->
      string_builder.from_string("fn (")
      |> string_builder.append(list_to_string(parameters))
      |> string_builder.append(") -> ")
      |> string_builder.append(to_string(return))
      |> string_builder.to_string
    NamespaceType(_) -> "<Namespace>"
  }
}

pub fn list_to_string(types: List(Type)) -> String {
  types
  |> iterator.from_list
  |> iterator.map(to_string)
  |> iterator.map(string_builder.from_string)
  |> iterator.to_list
  |> string_builder.join(", ")
  |> string_builder.to_string
}

pub fn to_glance(type_: Type) -> glance.Type {
  case type_ {
    NilType -> glance.NamedType("Nil", option.None, [])
    IntType -> glance.NamedType("Int", option.None, [])
    FloatType -> glance.NamedType("Float", option.None, [])
    StringType -> glance.NamedType("String", option.None, [])
    BoolType -> glance.NamedType("Bool", option.None, [])
    CustomType(name) -> glance.NamedType(name, option.None, [])
    CallableType(parameters, _labels, return) ->
      glance.FunctionType(list.map(parameters, to_glance), to_glance(return))
    NamespaceType(_) -> panic as "Cannot convert namespace to glance"
  }
}

pub fn to_binop_error(
  operator: String,
  left: Type,
  right: Type,
  expected: String,
) -> TypeResult {
  Error(error.InvalidBinOp(
    operator,
    left |> to_string,
    right |> to_string,
    expected,
  ))
}

import glance
import gleam/option
import glimpse/error

pub type Type {
  NilType
  IntType
  FloatType
  StringType
  BoolType
  CustomType(name: String)
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
  }
}

pub fn to_glance(type_: Type) -> glance.Type {
  case type_ {
    NilType -> glance.NamedType("Nil", option.None, [])
    IntType -> glance.NamedType("Int", option.None, [])
    FloatType -> glance.NamedType("Float", option.None, [])
    StringType -> glance.NamedType("String", option.None, [])
    BoolType -> glance.NamedType("Bool", option.None, [])
    // TODO: CustomType will need a module field
    CustomType(name) -> glance.NamedType(name, option.None, [])
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

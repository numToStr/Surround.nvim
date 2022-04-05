# BUGS

[ ] Multiline search is broken in some cases

```rust
impl_parse!(Scalar, {
    choice((
        just(TokenType::String).to(Scalar::String),
        just(TokenType::Boolean).to(Scalar::Boolean),
        just(TokenType::Int).to(Scalar::Int),
        just(TokenType::BigInt).to(Scalar::BigInt),
        just(TokenType::Float).to(Scalar::Float),
        just(TokenType::Decimal).to(Scalar::Decimal),
        just(TokenType::DateTime).to(Scalar::DateTime),
        just(TokenType::Json).to(Scalar::Json),
        just(TokenType::Bytes).to(Scalar::Bytes),
    ))
// | <------ Place you cursor here and do `cs(`
});
```

# TODO

[ ] Dot repeat

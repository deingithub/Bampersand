# Code style

Run `crystal tool format` over your code before committing to enforce standardized formatting.
Avoid line lengths over 80 characters, and if that's not possible, expand arguments into newlines as necessary, e.g. like:

```
SomeModule::very_long_function_invocation(
  "String argument", 123,
  {
    NamedTuple: "That couldn't fit",
    IntoALine: "With 80 chars"
  },
  :loremipsum
  )
```

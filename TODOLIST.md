# TODOLIST

## Tests

- [x] Raise if empty enum
- [x] Raise if duplicate keys
- [x] Raise if duplicate values
- [x] Raise if invalid fields
- [x] Raise if no default value for string-based enum
- [x] Raise if invalid value
- [x] Enums can be used in guards

## Features

- [x] @type enum_keys
- [x] @type enum_values
- [x] @type enum
- [x] Enums should support module attributes as fast access w/Macro.expand/2

## Prepare release

- [x] Add code coverage

## Documentation

- [x] Basic usage (Struct.cast)
- [x] Can be used in guard
- [x] Slow vs Fast access
- [x] Ecto enum Example
- [x] formatter.exs

## Proposals

- [ ] Custom Exception (EnumValueError) instead of ArgumentError for better pattern matching
- [ ] defenump
- [ ] @allow_duplicate_values true or @unique false to allow duplicates values
- [ ] is_enum/1, is_enum_key/1 & is_enum_value/1: eg. is_color(:red), is_color_key(:red) & is_color_value(:red)

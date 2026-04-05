# Changelog

## v1.0.0 (2026-04-05)

### Breaking changes

- **Removed legacy introspection via `name/1`**: `color(:__keys__)`,
  `color(:__values__)` and `color(:__enumerators__)` no longer work.
  Use the new dedicated helpers instead (see migration guide below).
- **Minimum Elixir version bumped to 1.16**.

### Migration from v0.1.0

Replace all legacy introspection calls:

```diff
- color(:__keys__)
+ color_keys()

- color(:__values__)
+ color_values()

- color(:__enumerators__)
+ color_enumerators()
```

If you defined custom guards like:

```diff
- defguard is_color(value) when value in color(:__keys__) or value in color(:__values__)
- defguard is_color_key(value) when value in color(:__keys__)
- defguard is_color_value(value) when value in color(:__values__)
```

You can remove them entirely, they are now generated automatically.

The following guards are now generated automatically:

- `is_color/1` - checks if a value is a valid key or value
- `is_color_key/1` - checks if a value is a valid key
- `is_color_value/1` - checks if a value is a valid value

### New features

- **Helpers**: `name_keys/0`, `name_values/0`, `name_enumerators/0` macros
  for compile-time access to enum data.
- **Guards**: `is_name/1`, `is_name_key/1`, `is_name_value/1` guard macros
  generated automatically for each enum.
- **Options**: `allow_duplicate_keys` and `allow_duplicate_values` for
  fine-grained control over duplicate validation.

### Improvements

- Internal refactoring for cleaner macro generation.
- Updated dependencies (`ex_doc ~> 0.40`).

## v0.1.0 (2021-12-26)

- Initial release

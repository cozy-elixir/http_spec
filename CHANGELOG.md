# Changelog

## Unreleased

### Breaking changes

- rename `build/1` to `new/1`
- rename `build!/1` to `new!/1`
- downcase header names when building a `%HTTPSpec.Response{}`

### New features

- add `HTTPSpec.Request.build_method/1`
- add `HTTPSpec.Request.build_url/1`
- add `HTTPSpec.Response.get_trailer/2`

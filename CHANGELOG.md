# Changelog

## Unreleased

- add `HTTPSpec.Request.URL`

## 2.1.0

- add `HTTPSpec.Request.put_query/2`
- add `HTTPSpec.Request.put_new_header/3`
- add `HTTPSpec.Request.put_new_lazy_header/3`
- add `HTTPSpec.Request.put_body/2`
- add `HTTPSpec.Request.Query`

## 2.0.0

### Breaking changes

- rename `build/1` to `new/1`
- rename `build!/1` to `new!/1`
- downcase header names when building a `%HTTPSpec.Response{}`

### New features

- add `HTTPSpec.Request.build_method/1`
- add `HTTPSpec.Request.build_url/1`
- add `HTTPSpec.Response.get_trailer/2`

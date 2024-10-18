# Changelog

## Unreleased

- rename `HTTPSpec.Request.Query` to `HTTPSpec.Request.QueryParams`.
- change default encoding of of `HTTPSpec.Request.QueryParams` to `:rfc3986`.
- rename `HTTPSpec.Request.URL.parse/1` to `HTTPSpec.Request.URL.parse!/1`
- add `HTTPSpec.Request.URL.parse/1` which returns ok/error tuple.

## 2.3.0

- add `:url` option for `HTTPSpec.Request.new/1` and `HTTPSpec.Request.new!/1`

## 2.2.0

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

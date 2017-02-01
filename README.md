# Query String Ruby filter plugin for Embulk

TODO: Write short description here and embulk-filter-query_string_ruby.gemspec file.

## Overview

* **Plugin type**: filter

## Configuration

- **column**: description (string, required)
- **query_params**: description (array, default: `[]`, required)

## Example

sample data
```
id,account,time,purchase,comment,query
1,32864,2015-01-27 19:23:49,20150127,embulk,http://hoge.com?hoge=aa&fuga=1
2,14824,2015-01-27 19:01:23,20150127,embulk jruby,?hoge=aa&fuga=1
3,27559,2015-01-28 02:20:02,20150128,"Embulk ""csv"" parser plugin",hoge=aa&fuga=1&piyo=2017-10-01
4,11270,2015-01-29 11:54:36,20150129,NULL,hoge=aafuga=1

```

configuration
```yaml
filters:
  - type: query_string_ruby
    column: query_string
    query_params: 
      - {name: hoge, type: string}
      - {name: fuga, type: long}
      - {name: piyo, type: timestamp, format: '%Y-%m-%d'}
```

result
```
+---------+--------------+-------------------------+-------------------------+----------------------------+--------------------------------+-------------+-----------+-------------------------+
| id:long | account:long |          time:timestamp |      purchase:timestamp |             comment:string |                   query:string | hoge:string | fuga:long |          piyo:timestamp |
+---------+--------------+-------------------------+-------------------------+----------------------------+--------------------------------+-------------+-----------+-------------------------+
|       1 |       32,864 | 2015-01-27 19:23:49 UTC | 2015-01-27 00:00:00 UTC |                     embulk | http://hoge.com?hoge=aa&fuga=1 |          aa |         1 |                         |
|       2 |       14,824 | 2015-01-27 19:01:23 UTC | 2015-01-27 00:00:00 UTC |               embulk jruby |                ?hoge=aa&fuga=1 |          aa |         1 |                         |
|       3 |       27,559 | 2015-01-28 02:20:02 UTC | 2015-01-28 00:00:00 UTC | Embulk "csv" parser plugin | hoge=aa&fuga=1&piyo=2017-10-01 |          aa |         1 | 2017-09-30 15:00:00 UTC |
|       4 |       11,270 | 2015-01-29 11:54:36 UTC | 2015-01-29 00:00:00 UTC |                            |                  hoge=aafuga=1 |    aafuga=1 |           |                         |
+---------+--------------+-------------------------+-------------------------+----------------------------+--------------------------------+-------------+-----------+-------------------------+
```


## Build

```
$ rake
```

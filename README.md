# host_keytab_facts

A structured fact containing information about `/etc/krb5.keytab`


## Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

If your host has a keytab in `/etc/krb5.keytab` and the `klist` utility installed,
this module will provide a structured fact about the content.

The format is `[principal][kvno][enc_type] = timestamp` for example:

```ruby
      {
        'HTTP/testify.example.com@EXAMPLE.COM' => {
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        },
        'host/testify.example.com@EXAMPLE.COM' => {
          '2' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2017 13:03:17'
          },
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        },
        'nfs/testify.example.com@EXAMPLE.COM' => {
          '3' => {
            '(DEPRECATED:des-cbc-crc)' => '10/07/2019 14:39:44',
            '(DEPRECATED:des3-hmac-sha1)' => '10/07/2019 14:39:44',
            '(aes128-cts-hmac-sha1-96)' => '10/07/2019 14:39:44',
            '(aes256-cts-hmac-sha1-96)' => '10/07/2019 14:39:44'
          }
        }
      }
```

## Usage

It is a fact, so long as the clients meet the requirements, it should be automatic.

## Limitations

This fact only exists on `Linux` hosts with `/etc/krb5.keytab` present (and in the right
format) that have `ktutil` in `$PATH`.


## Development

Development happens in the git repo linked here.

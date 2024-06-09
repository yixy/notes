Got error "invalid character 'ï' looking for beginning of value” from json.Unmarshal

```
body = bytes.TrimPrefix(body, []byte("\xef\xbb\xbf")) // Or []byte{239, 187, 191}

```
## ⚠️ Under development ⚠️
# Fabienne
Fabienne is a toy language, inspired by the kaleidoscope tutorial. 
[![Build Status](http://0b4bb36e.ngrok.io/buildStatus/icon?job=Fabienne)](http://0b4bb36e.ngrok.io/job/Fabienne/)

One of its main features, is a built in webserver.

## Example:
```ruby
# Can calculate fibonacii :)
def fib(x)
  if x < 3 then
    1
  else
    fib(x-1)+fib(x-2) 
end
fib(10)

def httpGet(route)
  fib(route)
end

httpStart()

```



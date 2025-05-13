package main
import rego.v1

array_contains(arr, elem) if {
  arr[_] = elem
}

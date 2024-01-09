// OOP: empty object
#let empty-object = (methods: (:))

// OOP: cal
#let call-or-display(self, fn) = {
  if type(fn) == function {
    return fn(self)
  } else {
    return fn
  }
}

// OOP: assuming all functions in dictionary have a named `self` parameter,
// `methods` function is used to get all methods in dictionary object
#let methods(self) = {
  assert(type(self) == dictionary, message: "self must be a dictionary")
  assert("methods" in self and type(self.methods) == dictionary, message: "self.methods must be a dictionary")
  let methods = (:)
  for key in self.methods.keys() {
    if type(self.methods.at(key)) == function {
      methods.insert(key, (..args) => self.methods.at(key)(self: self, ..args))
    }
  }
  return methods
}


// is sequence
#let is-sequence(it) = {
  type(it) == content and it.has("children")
}
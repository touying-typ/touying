// OOP: empty object
#let empty-object = (methods: (:))

// OOP: call it or display it
#let call-or-display(self, it) = {
  if type(it) == function {
    return it(self)
  } else {
    return it
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


// Type: is sequence
#let is-sequence(it) = {
  type(it) == content and it.has("children")
}
import test_exports

type
  PokemonVtable = object
    name: proc (this: pointer): string
    typ: proc (this: pointer): PokemonType
type
  Pokemon* = object
    objet: pointer
    vtable: ptr PokemonVtable
proc name*(this: Pokemon): string =
  this.vtable.name(this.objet)

proc typ*(this: Pokemon): PokemonType =
  this.vtable.typ(this.objet)

#implementInterface(Pokemon, true)

proc getPokemonVtable[T](): ptr PokemonVtable =
  var theVtable {.global.} = PokemonVtable(name: proc (this: pointer): string =
    mixin name
    var x = T(nil)
    when not (compiles(name(x))):
      {.fatal: "recursive call".}
    name(cast[T](this)), typ: proc (this: pointer): PokemonType =
    mixin typ
    var x = T(nil)
    when not (compiles(typ(x))):
      {.fatal: "recursive call".}
    typ(cast[T](this)))
  return addr(theVtable)

proc toPokemon*(this: ref): Pokemon =
  Pokemon(objet: cast[pointer](this), vtable: getPokemonVtable[type(this)]())


type
  LogSinkVtable = object
    log: proc (self: pointer; msg: string)
    messagesWritten: proc (self: pointer): int
type
  LogSink* = object
    objet: pointer
    vtable: ptr LogSinkVtable
proc log*(self: LogSink; msg: string) =
  self.vtable.log(self.objet, msg)

proc messagesWritten(self: LogSink): int =
  self.vtable.messagesWritten(self.objet)

#implementInterface(LogSink, true)

proc getLogSinkVtable[T](): ptr LogSinkVtable =
  var theVtable {.global.} = LogSinkVtable(log: proc (self: pointer; msg: string) =
    mixin log
    var x = T(nil)
    when not (compiles(log(x, msg))):
      {.fatal: "recursive call".}
    log(cast[T](self), msg), messagesWritten: proc (self: pointer): int =
    mixin messagesWritten
    var x = T(nil)
    when not (compiles(messagesWritten(x))):
      {.fatal: "recursive call".}
    messagesWritten(cast[T](self)))
  return addr(theVtable)

proc toLogSink*(this: ref): LogSink =
  LogSink(objet: cast[pointer](this), vtable: getLogSinkVtable[type(this)]())


type
  AnimalVtable = object
    makeNoise: proc (this: pointer): string
    legs: proc (this: pointer): int
    greet: proc (this: pointer; other: string): string
type
  Animal = object
    objet: pointer
    vtable: ptr AnimalVtable
proc makeNoise(this: Animal): string =
  this.vtable.makeNoise(this.objet)

proc legs(this: Animal): int =
  this.vtable.legs(this.objet)

proc greet(this: Animal; other: string): string =
  this.vtable.greet(this.objet, other)

#implementInterface(Animal, false)

proc getAnimalVtable[T](): ptr AnimalVtable =
  var theVtable {.global.} = AnimalVtable(makeNoise: proc (this: pointer): string =
    mixin makeNoise
    var x = T(nil)
    when not (compiles(makeNoise(x))):
      {.fatal: "recursive call".}
    makeNoise(cast[T](this)), legs: proc (this: pointer): int =
    mixin legs
    var x = T(nil)
    when not (compiles(legs(x))):
      {.fatal: "recursive call".}
    legs(cast[T](this)), greet: proc (this: pointer; other: string): string =
    mixin greet
    var x = T(nil)
    when not (compiles(greet(x, other))):
      {.fatal: "recursive call".}
    greet(cast[T](this), other))
  return addr(theVtable)

proc toAnimal(this: ref): Animal =
  Animal(objet: cast[pointer](this), vtable: getAnimalVtable[type(this)]())


type
  Human = ref object
    name: string
  Dog = ref object

proc makeNoise(human: Human): string =
  "Hello, my name is " & human.name

proc legs(human: Human): int = 2

proc greet(human: Human, other: string): string =
  "Nice to meet you, " & other

proc makeNoise(dog: Dog): string = "Woof! Woof!"

proc legs(dog: Dog): int = 4

proc greet(dog: Dog, other: string): string = "Woof! Woooof... wof!?"


proc interact(animal: Animal) =
  echo animal.makeNoise
  echo animal.greet("James Bond")

proc interactAll(animals: varargs[Animal, toAnimal]) =
  for animal in animals:
    animal.interact()

when isMainModule:
  var
    me = Human(name: "Andrea")
    bau = Dog()

    charmander = Charmander()
    espeon = Espeon()

  for animal in @[me.toAnimal, bau.toAnimal, charmander.toAnimal, espeon.toAnimal]:
    echo "Number of legs: ", legs(animal)
  for pokemon in @[charmander.toPokemon, espeon.toPokemon]:
    echo pokemon.name(), " is a ", pokemon.typ(), " Pokemon"

  interactAll(me, bau, charmander, espeon)


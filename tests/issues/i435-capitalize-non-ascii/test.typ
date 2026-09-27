// Regression test for https://github.com/touying-typ/touying/issues/435.
//
// `utils.capitalize` — and therefore `utils.titlecase`, the default
// `short-heading` label converter — dropped the first grapheme by slicing at
// byte index 1, which panics whenever the first character is not one ASCII
// byte. A single non-ASCII slide label killed the whole deck.

#import "/lib.typ": *

// ASCII behaviour must be unchanged.
#assert.eq(utils.capitalize(""), "")
#assert.eq(utils.capitalize("one"), "One")
#assert.eq(utils.capitalize("One"), "One")
#assert.eq(utils.titlecase("hello world"), "Hello World")

// Non-ASCII first graphemes must work, in whatever direction upper() goes.
#assert.eq(utils.capitalize("первый"), "Первый")
#assert.eq(utils.capitalize("Первый"), "Первый")
#assert.eq(utils.capitalize("école"), "École")
#assert.eq(utils.capitalize("Ёлка"), "Ёлка")
#assert.eq(utils.capitalize("日本語"), "日本語")
#assert.eq(utils.capitalize("🎉"), "🎉")
#assert.eq(utils.titlecase("первый слайд"), "Первый Слайд")

# Pharo String Interpolation

This package contains a compiler extension to add string interpolation to Pharo

## String Interpolation Examples

Interpolated Strings are literal strings that contain expressions, which are replaced by the results of those expressions.
String interpolation provides a readable way to compose strings out of expressions.

The following table contains examples of such strings:

| String        | Value           |
| ------------- |-------------|
| 'Constant 1 is {1}'      | 'Constant 1 is 1' |
| 'Result of 1+2 is {1+2}'      | 'Result of 1+2 is 3'      |
| 'Arbitrary expressions can be used as of {Date new}' |  'Arbitrary expressions can be used as of 11 February 2019'   |

Any expression valid within the context of the string is a valid interpolated expression.
This includes access to temporary variables, arguments, instance variables and so on...

## Activating String Interpolation

String interpolation is available as a compiler plugin that you may activate per class by redefining the `compiler` method:

```smalltalk
MyClass class >> compiler
	^super compiler addPlugin: StringInterpolationPlugin
```

From that moment on, you can use interpolated strings on any instance side method.

## Next Steps

- Getting syntax highlighting inside interpolated strings
- making string interpolation available for global scopes (such as class sides, playgrounds...)

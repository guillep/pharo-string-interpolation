Class {
	#name : #StringInterpolationTest,
	#superclass : #TestCase,
	#category : #StringInterpolation
}

{ #category : #compiler }
StringInterpolationTest class >> compiler [

	^super compiler addPlugin: StringInterpolationPlugin
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateExpression [

	self assert: '1+1 is {1 + 1}' equals: '1+1 is 2'
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateExpressionCallsAsString [

	self assert: 'self asString is {self}' equals: 'self asString is ', self asString
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateExpressionMixingContextWithConstants [

	| variable |
	variable := 2.
	self assert: '1 + variable is {1 + variable}' equals: '1 + variable is 3'
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateVariable [

	| variable |
	variable := 2.
	self assert: '1+1 is {variable}' equals: '1+1 is 2'
]

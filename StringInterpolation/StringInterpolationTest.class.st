Class {
	#name : #StringInterpolationTest,
	#superclass : #TestCase,
	#category : #StringInterpolation
}

{ #category : #compiler }
StringInterpolationTest class >> compiler [

	^super compiler addPlugin: StringInterpolationPlugin
]

{ #category : #compiler }
StringInterpolationTest class >> highlighter [

	^super highlighter
		addPlugin: StringInterpolationASTHighlighterPlugin
]

{ #category : #tests }
StringInterpolationTest >> testExpressionRaisingExceptionFailsAtRuntime [

	[ '{self error: ''example error''}' ]
		on: Error
		do: [ :error | 
			self assert: error messageText equals: 'example error' ]
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
StringInterpolationTest >> testInterpolateFailingExpressionThrowsSyntaxError [

	self
		should: [ self class compiler evaluate: ('''1+1 is \{1*}''' reject: [ :c | c = $\ ]) ]
		raise: SyntaxErrorNotification
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateStringSyntaxErrorHasStartAtTheBeginningOfTheFailingExpression [

	| stringToEvaluate |
	stringToEvaluate := '''1+1 is \{1*}''' reject: [ :c | c = $\ ].
	[
		self class compiler evaluate: stringToEvaluate.
		
		"Fail if the evaluation did not raise syntax error"
		self fail ]
	on: SyntaxErrorNotification
	do: [ :error | self assert: error location equals: (stringToEvaluate indexOf: ${) ]
]

{ #category : #tests }
StringInterpolationTest >> testInterpolateVariable [

	| variable |
	variable := 2.
	self assert: '1+1 is {variable}' equals: '1+1 is 2'
]

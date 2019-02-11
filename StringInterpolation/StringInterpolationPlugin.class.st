Class {
	#name : #StringInterpolationPlugin,
	#superclass : #OCCompilerASTPlugin,
	#category : #StringInterpolation
}

{ #category : #api }
StringInterpolationPlugin class >> interpolate: aString withAssociations: aCollection [

	| dictionaryValues |
	dictionaryValues := aCollection asDictionary.
	^ aString class new: aString size streamContents: [ :result | | stream |
		stream := aString readStream.
		[ stream atEnd ] whileFalse: [ | currentChar | 
			(currentChar := stream next) == ${
				ifTrue: [ | expression | 
					expression := stream upTo: $}.
					result nextPutAll: (dictionaryValues at: expression) asString ]
				ifFalse: [
					currentChar == $\
						ifTrue: [ stream atEnd ifFalse: [ result nextPut: stream next ] ]
						ifFalse: [ result nextPut: currentChar ] ] ] ]
]

{ #category : #private }
StringInterpolationPlugin class >> priority [
	^ 0
]

{ #category : #transforming }
StringInterpolationPlugin >> expandStringLiteral: aRBLiteralValueNode [ 
	
	| newMessageNode |
	(self hasInterpolationPattern: aRBLiteralValueNode value)
		ifFalse: [ ^ self ].

	newMessageNode := 	RBMessageNode
		receiver: (RBVariableNode named: StringInterpolationPlugin name)
		selector: #interpolate:withAssociations:
		arguments: {
			RBLiteralValueNode value: aRBLiteralValueNode value.
			RBArrayNode statements: (self extractStatementsFrom: aRBLiteralValueNode)}.
	
	aRBLiteralValueNode replaceWith: newMessageNode.
	
]

{ #category : #extracting }
StringInterpolationPlugin >> extractStatementsFrom: aLiteralValueNode [ 

	"Parses a string inside a literalValueNode and returns a collection of Message sends.
	The receiver of each message send is a string, with the same value as the interpolation pattern.
	The selector is #-> to create an association.
	The argument is an expression to evaluate to a value in the method."
	| messages stream stringToInterpolate |
	messages := OrderedCollection new.
	
	stringToInterpolate := aLiteralValueNode value.
	stream := stringToInterpolate readStream.
	[ stream atEnd ] whileFalse: [ | currentChar | 
		(currentChar := stream next) == ${
			ifTrue: [ | expression expressionPosition |
				expressionPosition := stream position. 
				expression := stream upTo: $}.
				messages add: (RBMessageNode
					receiver: (RBLiteralNode value: expression)
					selector: #->
					arguments: { [RBParser parseExpression: expression]
						on: SyntaxErrorNotification
						do: [ SyntaxErrorNotification 	
							inClass: Object
							withCode: ast sourceCode
							doitFlag: false
							errorMessage: 'Invalid syntax in pattern'
							location: expressionPosition + aLiteralValueNode start ] }) ]
			ifFalse: [
				currentChar == $\
					ifTrue: [ stream atEnd ifFalse: [ stream next ] ] ] ].
	^ messages
]

{ #category : #testing }
StringInterpolationPlugin >> hasInterpolationPattern: aString [ 
	
	"Any string with a {} pair is a potential interpolation target"
	^ aString matchesRegex: '.*{.*}.*'
]

{ #category : #api }
StringInterpolationPlugin >> transform [

	ast nodesDo: [ :each |
		(each isLiteralNode and: [ each value isString ])
			ifTrue: [ self expandStringLiteral: each ]  ].
	^ ast doSemanticAnalysis; yourself
]

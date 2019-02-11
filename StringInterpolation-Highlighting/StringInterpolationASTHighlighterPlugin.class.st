Class {
	#name : #StringInterpolationASTHighlighterPlugin,
	#superclass : #Object,
	#instVars : [
		'ast'
	],
	#category : #'StringInterpolation-Highlighting'
}

{ #category : #'instance creation' }
StringInterpolationASTHighlighterPlugin class >> ast: aRBMethodNode [ 
	
	^ self new
		ast: aRBMethodNode;
		yourself
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin class >> transform [
	self shouldBeImplemented.
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin class >> transform: ast [

	(self ast: ast) transform
]

{ #category : #accessing }
StringInterpolationASTHighlighterPlugin >> ast: aRBMethodNode [ 
	ast := aRBMethodNode
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin >> expandStringLiteral: aRBLiteralValueNode [
	
	| interpolatedStringNode |
	(StringInterpolationPlugin new hasInterpolationPattern: aRBLiteralValueNode value)
		ifFalse: [ ^ self ].
	
	interpolatedStringNode := 	RBInterpolatedStringNode
		on: aRBLiteralValueNode
		patterns: (self extractStatementsFrom: aRBLiteralValueNode).
	
	aRBLiteralValueNode replaceWith: interpolatedStringNode.
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin >> extractStatementsFrom: aRBLiteralValueNode [ 
	"Parses a string inside a literalValueNode and returns a collection of Message sends.
	The receiver of each message send is a string, with the same value as the interpolation pattern.
	The selector is #-> to create an association.
	The argument is an expression to evaluate to a value in the method."
	| messages stream stringToInterpolate |
	messages := OrderedCollection new.
	
	stringToInterpolate := aRBLiteralValueNode value.
	stream := stringToInterpolate readStream.
	[ stream atEnd ] whileFalse: [ | currentChar | 
		(currentChar := stream next) == ${
			ifTrue: [ | expression expressionPosition |
				expressionPosition := stream position. 
				expression := stream upTo: $}.
				messages add: (self
					updateIndexesOfNode: ([ (RBParser parseExpression: expression)]
						on: SyntaxErrorNotification
						do: [ RBParser parseFaultyExpression: expression ])
					startingAt: expressionPosition + aRBLiteralValueNode start) ]
			ifFalse: [
				currentChar == $\
					ifTrue: [ stream atEnd ifFalse: [ stream next ] ] ] ].
	^ messages
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin >> transform [

	ast nodesDo: [ :each |
		(each isLiteralNode and: [ each value isString ])
			ifTrue: [ self expandStringLiteral: each ]  ].
	^ ast
]

{ #category : #transforming }
StringInterpolationASTHighlighterPlugin >> updateIndexesOfNode: parent startingAt: offset [
	
	parent nodesDo: [ :node |
		(node respondsTo: #start:)
			ifTrue: [ node start: node start + offset ].
		(node respondsTo: #stop:)
			ifTrue: [ node stop: node stop + offset ] ].
	^ parent
]

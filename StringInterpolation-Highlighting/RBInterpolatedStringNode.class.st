Class {
	#name : #RBInterpolatedStringNode,
	#superclass : #RBLiteralNode,
	#instVars : [
		'stringNode',
		'patterns'
	],
	#category : #'StringInterpolation-Highlighting'
}

{ #category : #'instance creation' }
RBInterpolatedStringNode class >> on: aRBLiteralValueNode patterns: aCollection [ 
	
	^ self new
		stringNode: aRBLiteralValueNode;
		patterns: aCollection;
		yourself
]

{ #category : #visiting }
RBInterpolatedStringNode >> acceptVisitor: aVisitor [
	
	stringNode acceptVisitor: aVisitor.
	patterns do: [ :each | each acceptVisitor: aVisitor ]
]

{ #category : #visiting }
RBInterpolatedStringNode >> isFaulty [

	^ patterns anySatisfy: #isFaulty
]

{ #category : #testing }
RBInterpolatedStringNode >> isStringInterpolationNode [
	^ true
]

{ #category : #accessing }
RBInterpolatedStringNode >> patterns [
	^ patterns
]

{ #category : #accessing }
RBInterpolatedStringNode >> patterns: aCollection [

	patterns := aCollection.
	aCollection do: [ :each | each parent: self ]
]

{ #category : #accessing }
RBInterpolatedStringNode >> stringNode: aRBLiteralValueNode [ 
	
	stringNode := aRBLiteralValueNode
]

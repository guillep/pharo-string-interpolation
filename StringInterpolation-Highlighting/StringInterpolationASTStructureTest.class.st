Class {
	#name : #StringInterpolationASTStructureTest,
	#superclass : #TestCase,
	#instVars : [
		'ast',
		'sourceCode'
	],
	#category : #'StringInterpolation-Highlighting'
}

{ #category : #tests }
StringInterpolationASTStructureTest >> interpolationNode [

	^ ast statements first
]

{ #category : #tests }
StringInterpolationASTStructureTest >> setUp [

	super setUp.
	sourceCode := 'methodHeader ''{1*1}'''.
	ast := RBParser parseMethod: sourceCode.
	ast := (StringInterpolationASTHighlighterPlugin ast: ast) transform.
]

{ #category : #tests }
StringInterpolationASTStructureTest >> testASTHasStringInterpolationNode [
	
	self assert: ast statements first isStringInterpolationNode
]

{ #category : #tests }
StringInterpolationASTStructureTest >> testInterpolatedMessageStartCorrespondsToExpressionStartInString [

	| message |
	message := self interpolationNode patterns anyOne.
	self assert: message start equals: (sourceCode indexOf: ${) + 1
]

{ #category : #tests }
StringInterpolationASTStructureTest >> testInterpolationNodeHasMessageSend [
	
	self assert: self interpolationNode patterns anyOne isMessage
]

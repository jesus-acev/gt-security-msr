Class {
	#name : #BaselineOfGtSecurityMsr,
	#superclass : #BaselineOf,
	#category : #BaselineOfGtSecurityMsr
}

{ #category : #loading }
BaselineOfGtSecurityMsr class >> loadLepiter [
	IceRepository registry  
		detect: [ :aRepository |
			aRepository name = 'gt-security-msr' ]
		ifFound: [ :aRepository | 
			| defaultDatabase currentProperties |
			defaultDatabase := LeDatabasesRegistry defaultLogicalDatabase.
			currentProperties := defaultDatabase properties.
			currentProperties addRegisteredDirectory: aRepository repositoryDirectory / 'lepiter'.
			defaultDatabase reload ]
		ifNone: [
			self inform: 'Repository not found.' ]
]

{ #category : #baseline }
BaselineOfGtSecurityMsr >> baseline: spec [
	<baseline>
		^ spec for: #common do: [
			spec package: 'GtSecurityMsr'
		]
]

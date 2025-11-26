Extension { #name : #GtHome }

{ #category : #'*GtSecurityMsr' }
GtHome >> GtSecurityMsrSection [
	<gtHomeSection>
	^ GtHomeStartPageSection new
		title: 'GtSecurityMsr';
		description: 'Experimentando con GT';
		databaseName: 'jesus-acev/gt-security-msr/lepiter';
		startPageName: 'Security home';
		priority: 8
]

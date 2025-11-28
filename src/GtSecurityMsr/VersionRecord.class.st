Class {
	#name : #VersionRecord,
	#superclass : #Object,
	#instVars : [
		'timestampString',
		'vulnCount',
		'rawData'
	],
	#category : #'GtSecurityMsr-Model'
}

{ #category : #'as yet unclassified' }
VersionRecord class >> fromTimestampString: timestamp json: jsonDict [
    | vr |
    vr := self new.
    vr instVarNamed: 'timestampString' put: timestamp. "NO transformar"
    vr instVarNamed: 'rawData' put: jsonDict.
    vr instVarNamed: 'vulnCount' put: ((jsonDict at: 'vulnerability_list' ifAbsent: [ #() ]) size).
    ^ vr
]

{ #category : #'as yet unclassified' }
VersionRecord >> gtViewDetallesPrincipalesOn: aView [
    <gtView>
    ^ aView columnedList
        title: 'Detalles versión';
        items: {
            'Versión/timestamp' -> self timestampString.
            'Número de vulnerabilidades' -> self vulnCount.
        }.
]

{ #category : #'as yet unclassified' }
VersionRecord >> rawData [
    ^ rawData

]

{ #category : #'as yet unclassified' }
VersionRecord >> timestampString [
    ^ timestampString

]

{ #category : #'as yet unclassified' }
VersionRecord >> vulnCount [
    ^ vulnCount

]

{ #category : #'as yet unclassified' }
VersionRecord >> vulnerabilityCount [
    ^ vulnCount
]

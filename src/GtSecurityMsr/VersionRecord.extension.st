Extension { #name : #VersionRecord }

{ #category : #'*GtSecurityMsr' }
VersionRecord class >> fromTimestampString: timestamp json: jsonDict [
    | vr |
    vr := self new.
    vr instVarNamed: 'timestampString' put: timestamp. "NO transformar"
    vr instVarNamed: 'rawData' put: jsonDict.
    vr instVarNamed: 'vulnCount' put: ((jsonDict at: 'vulnerability_list' ifAbsent: [ #() ]) size).
    ^ vr
]

{ #category : #'*GtSecurityMsr' }
VersionRecord >> gtViewDetallesPrincipalesOn: aView [
    <gtView>
    ^ aView columnedList
        title: 'Detalles versión';
        items: {
            'Versión/timestamp' -> self timestampString.
            'Número de vulnerabilidades' -> self vulnCount.
        }.
]

{ #category : #'*GtSecurityMsr' }
VersionRecord >> rawData [
    ^ rawData

]

{ #category : #'*GtSecurityMsr' }
VersionRecord >> timestampString [
    ^ timestampString

]

{ #category : #'*GtSecurityMsr' }
VersionRecord >> vulnCount [
    ^ vulnCount

]

{ #category : #'*GtSecurityMsr' }
VersionRecord >> vulnerabilityCount [
    ^ vulnCount
]

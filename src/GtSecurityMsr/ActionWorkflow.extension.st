Extension { #name : #ActionWorkflow }

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> addVersion: aVersionRecord [
    versions add: aVersionRecord

]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> baseRectangleSize [
    "Tamaño mínimo visible para vulnerabilidades = 0."
    ^ 10    "¡Ahora es 10!"
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow class >> fromDictionaries: aCollectionOfDicts [
    "Devuelve una colección de ActionWorkflow a partir de una colección de diccionarios JSON (ya parseados)."
    ^ aCollectionOfDicts collect: [ :dict | self fromJson: dict ]
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow class >> fromJson: jsonDict [
    | aw history |
    aw := self new.
    aw rawJson: jsonDict.
    aw repoOwner: (jsonDict at: 'repo_owner' ifAbsent: [ nil ]).
    aw repoName: (jsonDict at: 'repo_name' ifAbsent: [ nil ]).
    aw workflowName: (jsonDict at: 'workflow_name' ifAbsent: [ nil ]).
    history := jsonDict at: 'history' ifAbsent: [ Dictionary new ].
    history keysAndValuesDo: [ :timestamp :data |
        aw addVersion: (VersionRecord fromTimestampString: timestamp json: data)
    ].
    ^ aw
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> gtViewVersionRectsOn1: aView [
    <gtView>
    ^ aView explicit
        title: 'Rectángulos por versión(Final)';
        stencil: [ self visualizeVersionsAsRectanglesInView: aView ]
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> gtViewVersionRectsOn: aView [
    <gtView>
    ^ aView explicit
        title: 'Rectángulos por versión (Primera version)';
        stencil: [ self visualizeVersionsAsRectangles]
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> hasManyVersions [
    "5 o más versiones"
    ^ self versionCount >= 5
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> initialize [
    super initialize.
    versions := OrderedCollection new.
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow class >> loadAllFromDirectory: baseDirectory [
    | files |
    files := baseDirectory allChildrenMatching: '*.json'.
    ^ files collect: [ :jsonFile |
        | dict |
        dict := STONJSON fromString: jsonFile contents.
        self fromJson: dict
    ]
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> rawJson [
    ^ rawJson
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> rawJson: aDict [
    rawJson := aDict
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> rectangleScaleFactor [
    "Ajusta el tamaño sin cambiar la métrica base. Por ejemplo, 10 hace los rectángulos 10x más grandes."
    ^ 35
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> repoName [
    ^ repoName

]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> repoName: aString [
    repoName := aString
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> repoOwner [
    ^ repoOwner
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> repoOwner: aString [
    repoOwner := aString

]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> totalVulnerabilities [
    ^ versions sum: [ :v | v vulnCount ]
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> versionCount [
    ^ versions size
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> versions [
    ^ versions
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> visualizeColor [
    ^ self hasManyVersions
        ifTrue: [ Color r: 0.2 g: 0.8 b: 0.2 ]   "Verde"
        ifFalse: [ Color r: 0.9 g: 0.2 b: 0.2 ]  "Rojo"
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> visualizeVersionsAsRectangles [
    "Devuelve un BlElement con un rectángulo por versión:
     - ancho y alto = métrica 1 (vulnerabilidades) escalada por rectangleScaleFactor
     - color = rojo si el archivo tiene <5 versiones, verde si tiene >=5
     - sin abrir nuevas ventanas al click; muestra detalles inline como texto sobre el rectángulo"
    | container color scale |
    container := BlElement new
        layout: BlFlowLayout horizontal;
        constraintsDo: [ :c |
            c horizontal fitContent.
            c vertical fitContent ];
        padding: (BlInsets all: 20);
        background: Color white;
        yourself.

    color := self visualizeColor.
    scale := self rectangleScaleFactor.

    self versions do: [ :v |
        | base size squareElement titleLabel infoLabel |
        base := v vulnerabilityCount asInteger.
        size := base * scale.

        squareElement := BlElement new
            geometry: BlRectangleGeometry new;
            size: size @ size;
            background: color;
            border: (BlBorder paint: Color black width: 1);
            margin: (BlInsets all: 8);
            yourself.

        "Título: timestamp"
        titleLabel := BlTextElement new
            text: (v timestampString asRopedText
                fontSize: 14;
                foreground: Color white;
                bold);
            yourself.

        squareElement addChild: titleLabel.
        titleLabel relocate: 6 @ 6.

        "Info inline: vuln count y # versiones (métricas 1 y 2)"
        infoLabel := BlTextElement new
            text: (('Vulns: ', base asString, '  Vers: ', self versionCount asString) asRopedText
                fontSize: 16;
                foreground: Color white;
                bold);
            yourself.

        squareElement addChild: infoLabel.
        infoLabel relocate: 6 @ (size - 26 max: 6).

        "Interacción sin abrir nuevas ventanas: hover resalta borde, click alterna grosor"
        squareElement addEventHandler: (BlEventHandler
            on: BlMouseEnterEvent
            do: [ :evt |
                squareElement border: (BlBorder paint: Color yellow width: 3) ]).
        squareElement addEventHandler: (BlEventHandler
            on: BlMouseLeaveEvent
            do: [ :evt |
                squareElement border: (BlBorder paint: Color black width: 1) ]).
        squareElement addEventHandler: (BlEventHandler
            on: BlClickEvent
            do: [ :evt |
                "Toggle del grosor del borde, no abre otra ventana"
                | current |
                current := squareElement border width.
                squareElement border: (BlBorder paint: Color cyan width: (current = 3 ifTrue: [ 1 ] ifFalse: [ 3 ])).
                evt consumed: true ]).

        container addChild: squareElement.
    ].

    ^ container
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> visualizeVersionsAsRectanglesInView: aView [
    "Visualiza cada versión como un cuadrado, acomodados de izquierda a derecha;
    al llegar al límite derecho, pasa a otra fila más abajo (horizontal row wrap).
    Incluye zoom y pan."

    | mainContainer currentX currentY maxRowHeight maxX scale baseSize zoomableContainer |
    mainContainer := BlElement new
        background: Color white;
        size: 3000 @ 1300;  "Tamaño base, puedes ajustar"
        clipChildren: false;
        yourself.

    "Componente zoom y pan"
    zoomableContainer := BlZoomableElement new
        size: 1600 @ 800;
        clipChildren: false;
        contentElement: mainContainer;
        yourself.

    scale := self rectangleScaleFactor.      "Por ejemplo, 30"
    baseSize := self baseRectangleSize.      "Por ejemplo, 10"
    maxX := 2400.       "Límite derecho, ajusta según pantalla"
    currentX := 20.
    currentY := 20.
    maxRowHeight := 0.

    self versions do: [ :v |
        | vulnCount size squareElement label1 label2 |
        vulnCount := v vulnerabilityCount asInteger.
        size := baseSize + (vulnCount * scale).

        squareElement := BlElement new
            geometry: BlRectangleGeometry new;
            size: size @ size;
            background: self visualizeColor;
            border: (BlBorder paint: Color black width: 2);
            yourself.

        label1 := BlTextElement new
            text: (('Versión: ', v timestampString) asRopedText
                fontSize: 12; foreground: Color white; bold);
            yourself.
        label2 := BlTextElement new
            text: (('# Vulnerabilidades: ', vulnCount asString) asRopedText
                fontSize: 12; foreground: Color white; bold);
            yourself.

        squareElement addChild: label1.
        label1 relocate: 6 @ 6.
        squareElement addChild: label2.
        label2 relocate: 6 @ (size - 22 max: 6).

        squareElement addEventHandler: (BlEventHandler
            on: BlMouseEnterEvent
            do: [ :evt | squareElement border: (BlBorder paint: Color yellow width: 4) ]).
        squareElement addEventHandler: (BlEventHandler
            on: BlMouseLeaveEvent
            do: [ :evt | squareElement border: (BlBorder paint: Color black width: 2) ]).
        squareElement addEventHandler: (BlEventHandler
            on: BlClickEvent
            do: [ :evt |
                (aView respondsTo: #setObject:)
                    ifTrue: [ aView setObject: v ]
                    ifFalse: [ squareElement phlow spawnObject: v ].
                evt consumed: true ]).

        "==== Posicionamiento manual fila-horizontales ===="
        squareElement relocate: currentX @ currentY.
        "Actualiza el máximo alto en la fila"
        maxRowHeight := maxRowHeight max: size.

        "Avanza a la derecha"
        currentX := currentX + size + 20.

        "¿Saltamos de fila? Si pasamos del borde derecho"
        (currentX + size > maxX) ifTrue: [
            currentX := 20.                       "Volvemos a la izquierda"
            currentY := currentY + maxRowHeight + 22.  "Bajamos"
            maxRowHeight := 0.
        ].
        "==== Fin del posicionamiento fila-horizontal ===="

        mainContainer addChild: squareElement.
    ].

    "Ajusta el tamaño del contenedor grande si quieres (opcional)"
    mainContainer size: (maxX + 100) @ (currentY + maxRowHeight + 80).

    "Permite pan y zoom"
    ^ zoomableContainer asPannableElement
]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> workflowName [
    ^ workflowName

]

{ #category : #'*GtSecurityMsr' }
ActionWorkflow >> workflowName: aString [
    workflowName := aString
]

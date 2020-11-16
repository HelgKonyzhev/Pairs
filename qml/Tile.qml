import QtQuick 2.12

Flipable {
	id: flipable
	property alias frontImageSource: frontImage.source
	property alias backImageSource: backImage.source
	property bool flipped: false
	property bool clickable: true

	front: Rectangle {
		anchors.fill: parent; border.width: 2; border.color: "lightsteelblue"
		Image { id: frontImage; anchors.fill: parent }
	}
	back: Rectangle {
		anchors.fill: parent; border.width: 2; border.color: "lightsteelblue"
		Image { id: backImage; anchors.fill: parent }
	}

	transform: Rotation {
		id: rotation
		origin.x: flipable.width / 2
		origin.y: flipable.height / 2
		axis.x: 0; axis.y: 1; axis.z: 0
		angle: 0
	}

	states: State {
		PropertyChanges { target: rotation; angle: 180 }
		when: flipable.flipped
	}

	transitions: Transition {
		id: flippingTransition
		NumberAnimation { target: rotation; property: "angle"; duration: 100; }
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			if(clickable && !flipped && !flippingTransition.running)
				flipable.flipped = true
		}
	}
}

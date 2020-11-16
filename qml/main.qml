import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.15
import "qrc:/qml"

Window {
	id: window
	title: "Pairs"
	visible: true
	property int tileWidth: 72
	property int tileHeight: 72
	property int restartButtonHeight: 30
	property int tilesSpacing: 2
	property int horizontalTilesCount: 10
	property int verticalTilesCount: 10
	property int tilesCount: horizontalTilesCount * verticalTilesCount
	width: tileWidth * horizontalTilesCount + (horizontalTilesCount - 1) * tilesSpacing + 20
	height: tileHeight * verticalTilesCount + (verticalTilesCount - 1) * tilesSpacing + restartButtonHeight
	property var flippedTiles: []
	property int triesCount: 0
	property int totalSecondsPassed: 0
	property int matchCount: 0

	Grid {
		id: gameField
		rows: horizontalTilesCount
		columns: verticalTilesCount
		spacing: tilesSpacing
		visible: true
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top

		Repeater {
			id: tilesRepeater
			model: tilesCount
			property var imagesIndexes: []

			function randomInt(max) {
				return Math.floor(Math.random() * Math.floor(max));
			}

			function getImageSource()
			{
				if(imagesIndexes.length === 0) {
					for(var i = 0; i < tilesCount; i++)
						imagesIndexes.push(Math.floor(i / 2))
				}

				var index = randomInt(imagesIndexes.length)
				var source = "qrc:/res/" + imagesIndexes[index] + ".png"
				imagesIndexes.splice(index, 1)
				return source
			}

			Tile {
				width: tileWidth
				height: tileHeight
				frontImageSource: "qrc:/res/front.png";
				backImageSource: tilesRepeater.getImageSource()
				onFlippedChanged: tileFlipped(tilesRepeater.itemAt(index))
			}
		}
	}

	Rectangle {
		id: gameResults
		anchors.centerIn: parent
		visible: false
		width: 200
		height: 50

		Column {
			anchors.horizontalCenter: parent.horizontalCenter
			anchors.top: parent.top

			Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Congratulations!" }
			Text { anchors.horizontalCenter: parent.horizontalCenter; text: "You made " + triesCount + " tries in " + totalSecondsPassed + " second" }
		}
	}

	Button {
		id: restartButton
		height: restartButtonHeight
		anchors.bottom: parent.bottom

		onClicked: {
			flippedTiles.length = 0
			triesCount = 0
			totalSecondsPassed = 0
			matchCount = 0
			tilesRepeater.model = 0
			tilesRepeater.model = tilesCount
			showResults(false)
			totalSecondsTimer.start()
		}
	}

	Timer {
		id: mismatchTimer
		interval: 500; running: false; repeat: false
		onTriggered: {
			flippedTiles[0].flipped = false
			flippedTiles[1].flipped = false
			flippedTiles.length = 0

			for(var i = 0; i < tilesRepeater.count; i++)
				tilesRepeater.itemAt(i).clickable = true
		}
	}

	Timer {
		id: totalSecondsTimer
		interval: 1000; running: true; repeat: true; triggeredOnStart: true
		onTriggered: { ++totalSecondsPassed }
	}

	onTotalSecondsPassedChanged: {
		var minutes = Math.floor(totalSecondsPassed / 60)
		var seconds = totalSecondsPassed - minutes * 60
		restartButton.text = (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds
	}

	function showResults(show) {
		gameField.visible = !show
		gameResults.visible = show
	}

	function tileFlipped(tile) {
		flippedTiles.push(tile)

		if(flippedTiles.length === 2) {
			++triesCount

			if(flippedTiles[0].backImageSource !== flippedTiles[1].backImageSource) {
				for(var i = 0; i < tilesRepeater.count; i++) {
					var t = tilesRepeater.itemAt(i)
					if(!flippedTiles.includes(t))
						t.clickable = false
				}

				mismatchTimer.start()
			} else {
				++matchCount
				flippedTiles.length = 0

				if(matchCount === tilesCount / 2) {
					totalSecondsTimer.stop()
					showResults(true)
				}
			}
		}
	}
}

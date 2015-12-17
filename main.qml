import QtQuick 2.0
import Bacon2D 1.0
import QtQml 2.2

Game
{
    width: 568
    height: 320

    gameName: "com.ubuntu.developer.xcub.SwitchDash"
    currentScene: gameScene
    Scene
    {
        id: gameScene
        anchors.fill: parent
        physics: false
        gravity: Qt.point(0.0, 0.0)
        property var colors: [
            "red", "orange", "yellow", "green", "blue", "purple", "indigo"
        ]
        property int colorCounter: 0
        property int score: 0
        property bool gameOver: false
        Rectangle
        {
            id: upperRect
            width: parent.width
            height: parent.height / 2
            y: 0.0
            color: "black"
        }

        Rectangle
        {
            id: lowerRect
            width: parent.width
            height: parent.height / 2
            y: parent.height / 2
            color: "white"
        }

        Component
        {
            id: block
            Entity
            {
                width: 60
                height: 40
                property alias color: visiblePart.color
                x: gameScene.width - width
                updateInterval: 15
                property bool hasFlashed: false
                behavior: ScriptBehavior {
                    script: {
                        if (gameScene.gameOver)
                            target.destroy();
                        if (target.y === player.y)
                        {
                            if ((target.x >= player.x) && (target.x <= (player.x + player.width)))
                            {
                                player.destroy();
                                target.destroy();
                                gameScene.gameOver = true;
                                blockSpawner.running = false;
                                gameOverText.visible = true;
                            }
                        }

                        if (target.x <= player.x && !target.hasFlashed)
                        {
                            gameScene.score++;
                            flash.start();
                            target.hasFlashed = true;
                            if (gameScene.colorCounter === gameScene.colors.length - 1)
                                gameScene.colorCounter = 0;
                            else
                                gameScene.colorCounter++;
                        }

                        else if (target.x <= -target.width)
                        {
                            target.destroy();
                        }
                    }
                }



                PropertyAnimation {
                    id: flash
                    target: visiblePart
                    property: "color"
                    to: gameScene.colors[gameScene.colorCounter]
                    duration: 200
                }

                Rectangle
                {
                    id: visiblePart
                    anchors.fill: parent
                }

            }
        }

        Entity
        {
            id: player
            width: 30
            height: 40
            property alias color: visiblePart.color
            x: gameScene.width / 3
            y: lowerRect.y - height
            Rectangle
            {
                id: visiblePart
                anchors.fill: parent
                color: "white"
            }

            Behavior on y
            {
                NumberAnimation {duration: 50}
            }

            function switchPosition()
            {
                if (player.y === (lowerRect.y - player.height))
                {
                    player.y = lowerRect.y;
                    visiblePart.color = "black";
                }
                else
                {
                    player.y = lowerRect.y - player.height;
                    visiblePart.color = "white";
                }
            }
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: {
                if (!gameScene.gameOver)
                    player.switchPosition();
            }
        }

        Layer
        {
            id: scrollLayer
            anchors.fill: parent
            behavior: ScrollBehavior {
                horizontalStep: -10
            }
        }

        Text
        {
            id: scoreText
            color: "white"
            font.family: "Courier 10 Pitch"
            x: upperRect.width / 2 - width / 2
            y: upperRect.height / 2 - height / 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 50
            text: gameScene.score
        }

        Text
        {
            id: gameOverText
            color: "black"
            font.family: "Courier 10 Pitch"
            x: lowerRect.width / 2 - width / 2
            y: lowerRect.y + lowerRect.height / 2 - height / 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 50
            text: "Game Over"
            visible: false
        }

        Timer
        {
            id: blockSpawner
            running: true
            repeat: true
            interval: 1000
            onTriggered:
            {
                var decider= Math.floor(Math.random()*(11-8+1)+8);
                var isOnTop = 0;
                if (decider >= 8 && decider <=9)
                    isOnTop = 1;
                else
                    isOnTop = 0;

                var newBlock = block.createObject(scrollLayer);
                if (isOnTop)
                {
                    newBlock.color = "white";
                    newBlock.y = lowerRect.y - newBlock.height;
                }
                else
                {
                    newBlock.color = "black";
                    newBlock.y = lowerRect.y;
                }
            }
        }

    }
}

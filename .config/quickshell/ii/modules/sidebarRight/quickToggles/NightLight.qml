import qs.modules.common
import qs.modules.common.widgets
import qs
import Quickshell.Io

QuickToggleButton {
    id: nightLightButton
    property bool enabled: false
    toggled: enabled
    buttonIcon: "nightlight"
    onClicked: {
        nightLightButton.enabled = !nightLightButton.enabled
        if (enabled) {
            nightLightOn.startDetached()
        } 
        else {
            nightLightOff.startDetached()
        }
    }
    Process {
        id: nightLightOn
        command: ["gammastep"]
    }
    Process {
        id: nightLightOff
        command: ["pkill", "gammastep"]
    }
    Process {
        id: updateNightLightState
        running: true
        command: ["pidof", "gammastep"]
        stdout: SplitParser {
            onRead: (data) => { // if not empty then set toggled to true
                nightLightButton.enabled = data.length > 0
            }
        }
    }
    StyledToolTip {
        content: Translation.tr("Night Light")
    }
}

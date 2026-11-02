import QtQuick
import qs.Commons
import qs.Ui

WidgetButton {
  id: root

  text: "\uF303"
  tooltipText: "Omarchy Menu\n\nSuper + Alt + Space"
  horizontalMargin: 7.5
  verticalPadding: 6
  fontSize: 14

  onPressed: function(button) {
    if (!root.bar) return
    if (button === Qt.RightButton)
      root.bar.run("uwsm app -- xdg-terminal-exec")
    else
      root.bar.run("omarchy-menu toggle root")
  }
}

import { execAsync } from 'astal'

const QuickAccess = () => {
  const colorPickerCmd = 'hyprpicker -a -f hex -r'
  const screenshotCmd = 'hyprshot --mode region'

  const cpButton = (
    <eventbox
      widthRequest={18}
      onClick={async () => await execAsync(colorPickerCmd)}
    >
      
    </eventbox>
  )
  const ssButton = (
    <eventbox
      widthRequest={18}
      onClick={async () => await execAsync(screenshotCmd)}
    >
      󰹑
    </eventbox>
  )

  return (
    <box spacing={5}>
      {cpButton}
      {ssButton}
    </box>
  )
}

export default QuickAccess

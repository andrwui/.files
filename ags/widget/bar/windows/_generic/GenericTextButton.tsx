import { Widget } from 'astal/gtk3'

interface GenericTextButtonProps extends Widget.EventBoxProps {
  children?: JSX.Element | JSX.Element[]
}
const GenericTextButton = ({ children, ...props }: GenericTextButtonProps) => {
  return (
    <eventbox
      {...props}
      cursor={'pointer'}
      className={`smallText ${props.className}`}
    >
      {children}
    </eventbox>
  )
}

export default GenericTextButton

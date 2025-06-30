import { BoxProps } from 'astal/gtk3/widget'

export default function LayoutContainer({ children, name, ...props }: BoxProps) {
  return (
    <box
      {...props}
      hexpand
      name={name}
    >
      {children}
    </box>
  )
}
